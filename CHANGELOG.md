# Changelog

All notable changes to this config are documented here.

## [Unreleased]

### Changed
- **Colorscheme: `rose-pine` → `islands-dark`, ported directly from the user's real
  RustRover "Islands Dark" scheme.** "Islands" itself is JetBrains' 2025 UI-chrome
  redesign (rounded corners, panel spacing) — not a distinct syntax palette — confirmed
  by checking JetBrains' own announcement post, which describes only layout changes and
  publishes no color values. The actual editor colors are still Darcula-derived
  (`parent_scheme="Darcula"` in the exported file). Rather than guess at hex values, the
  user exported their scheme from RustRover (Settings → Editor → Color Scheme →
  Export → `.icls`) and every color in `lua/config/colors/islands-dark.lua` is read
  directly from that file's real hex values — background `#191a1c`, foreground `#bcbec4`,
  keywords `#cf8e6d`, strings `#6aab73`, numbers `#2aacb8`, functions `#56a8f5`,
  constants/fields `#c77dbb`, etc. Replaces `rose-pine/neovim` entirely (dropped from
  `lazy-lock.json`); loaded as a local, non-cloned `lazy.nvim` spec (`dir =
  vim.fn.stdpath("config")`) rather than an external plugin, since it's a one-off port
  specific to this exported theme, not a general-purpose published colorscheme. Verified:
  confirmed `Normal`'s fg/bg resolve to the exact source hex values byte-for-byte, and
  re-ran the same lualine per-mode color-differentiation check from the earlier
  statusline work against the new palette (still passes — `lualine_a_normal` /
  `_insert` / `_visual` all resolve to distinct backgrounds under the new colors).
  `DiagnosticVirtualText*` groups explicitly link to their base `Diagnostic*` groups from
  the start, avoiding the fg==bg invisibility bug rose-pine had.

### Added
- `lualine.nvim` for a real statusline mode indicator. Previously there was no statusline
  plugin at all — the "mode name at the bottom" the user was seeing was Neovim's own
  `showmode` echo-area message (`-- INSERT --`), which isn't colored and only redraws on
  certain events, reading as "stuck." Configured with `theme = "auto"` (derives colors
  from the active colorscheme's highlight groups, so it follows rose-pine without a
  dedicated theme) and `globalstatus = true` (one statusline for the whole editor, not one
  per split). `showmode` turned off since the statusline now covers it. Verified with real
  evidence: confirmed lualine's per-mode highlight groups (`lualine_a_normal`,
  `lualine_a_insert`, `lualine_a_visual`) resolve to genuinely different background colors,
  and confirmed the rendered statusline text switches from `NORMAL` to `VISUAL` on an
  actual mode change (`normal! v`) evaluated via `nvim_eval_statusline`. Insert-mode text
  couldn't be verified the same way — `startinsert` doesn't perform a real mode transition
  in headless Neovim without an attached UI (confirmed separately: `vim.fn.mode()` stays
  `"n"` after it), the same category of headless-simulation limitation noted elsewhere in
  this log — but the underlying mechanism (lualine's `mode` component reads
  `vim.fn.mode()` on every redraw) is identical for all modes, so this isn't a gap in the
  fix, just in what headless automation can simulate.

### Fixed
- **Regression from the previous release: `vim.cmd.helptags(...)` (and any other
  dot-call form of `vim.cmd`, e.g. `vim.cmd.write()`) threw `attempt to index field
  'cmd' (a function value)`.** The `didSave` fix in `auto-save.lua` replaced
  `vim.cmd` outright with a plain function to intercept its string-call form -
  but `vim.cmd` is a callable *table* that also supports dot-access
  (`vim.cmd.write()`, `vim.cmd.help()`, etc.), and a plain function has no fields
  to index. This broke lazy.nvim's own periodic doc-update routine
  (`lazy/help.lua:43: vim.cmd.helptags(...)`) in practice, visibly, in a live
  session. Fixed with a proper `setmetatable` proxy: `__index` forwards dot-access
  to the untouched original `vim.cmd`, `__call` intercepts only the plain
  string-call form. Verified against the exact failing call
  (`vim.cmd.helptags(...)`) plus a couple other dot-call forms, and re-verified
  both the `didSave` notification and the format-on-save skip still work
  unchanged - no regression on the fix this was fixing.

### Added
- `<Tab>` now confirms the selected completion item, same as `<C-y>` - but only
  when the completion menu is actually open; otherwise it falls through to
  normal `Tab` behavior. Standard `cmp.mapping()` + `fallback()` pattern.

### Fixed
- **Still needed to leave insert mode for the didSave fix (above) to kick in.**
  `auto-save.nvim`'s `defer_save` trigger events were `{"InsertLeave", "TextChanged"}` -
  but `TextChanged` only fires for edits made *outside* insert mode; its insert-mode
  counterpart is `TextChangedI`, which was missing. So the debounced save (and the
  `didSave` notify riding on it) never fired while actively typing, only once `Esc` was
  pressed. Added `TextChangedI` to both the plugin's lazy-load `event` and
  `defer_save`. The debounce implementation cancels and reschedules its timer on every
  trigger (confirmed by reading `auto-save.nvim`'s own source), so this doesn't cause a
  save flood while typing - it still only fires ~1s after you *stop*, just without
  needing a mode switch first. Verified end-to-end with `InsertLeave` never fired at
  all in the test: diagnostic appeared in ~1.5s from `TextChangedI` alone.

- **Diagnostics never refreshed without a manual `:w`, even after `update_in_insert`.**
  Root-caused with hard evidence, not guessed: `auto-save.nvim`'s `noautocmd = true`
  (added specifically so autosaves wouldn't trigger format-on-save) suppresses *all*
  autocmds during the write — including the LSP client's own `BufWritePost`-triggered
  `textDocument/didSave`, which rust-analyzer's on-save diagnostic refresh
  (`check.command = "clippy"`) depends on. Confirmed directly: a `noautocmd write` sends
  zero LSP notifications; a normal `write` sends `didSave`. Also confirmed the rest of
  the pipeline was fine along the way - `didChange` fires correctly on every edit,
  document sync is correct (verified via `hover` reflecting brand-new code within
  seconds), and Neovim's own pull-diagnostic auto-refresh is wired automatically on
  attach - the gap was specifically the missing `didSave`.

  Fixed in `auto-save.lua` by wrapping `vim.cmd` narrowly: only for the exact command
  string `auto-save.nvim` builds internally, manually send `textDocument/didSave` right
  after the real (synchronous) write completes - correctly ordered, no vendored plugin
  patched, format-on-save still correctly skipped for autosaves. Verified end-to-end
  with zero manual saves involved: typed an error, waited for autosave's own debounce
  cycle, diagnostic appeared in ~1.5s.

- **Diagnostic virtual text was rendering invisible.** rose-pine's own
  `DiagnosticVirtualText{Error,Warn,Info,Hint,Ok}` groups set `fg == bg` (with a blend),
  so the inline error/warning message text was the same color as its own background —
  the extmark was genuinely being drawn (confirmed via `nvim_buf_get_extmarks`), it just
  couldn't be seen. Its `DiagnosticSign*` groups already correctly link to the fg-only
  `Diagnostic*` groups; extended that same pattern to the virtual text groups in
  `misc.lua`, after the colorscheme loads.
- **Diagnostics appeared to require `:w` to update.** Neovim's `update_in_insert`
  defaults to `false` (diagnostics only redraw on `InsertLeave`, not while still typing)
  — since `Esc` always precedes `:w`, it read as "only updates on save" when it was
  really "only updates on leaving insert mode." Set `update_in_insert = true` in
  `lsp.lua` for RustRover-style continuous feedback while actively typing. Confirmed
  correct against Neovim's own documented semantics for this option; the live
  while-still-in-insert-mode behavior itself couldn't be synthetically verified in
  headless automation (same category of limitation as simulated keypresses elsewhere in
  this project), so this one is verified by mechanism/docs rather than a headless repro.

### Added
- `nvim-lightbulb` — shows a 💡 sign in the gutter whenever a code action (quick fix,
  suggestion, auto-import, etc.) is available at the cursor, same idea as JetBrains'
  lightbulb icon. `<leader>vca` already triggered code actions; this makes it visible
  *when* one exists instead of needing to check manually. Verified end-to-end: set up a
  real local ESLint install + flat config in a test project, confirmed the LSP itself
  flags a real lint violation (`source=eslint code=eqeqeq`), confirmed a code action is
  genuinely offered for it, and confirmed the lightbulb sign gets placed on that exact
  line.

### Verified (no code change)
- ESLint (`vscode-eslint-language-server` via Mason) resolves ESLint from the **project's
  own** `node_modules` — it does nothing without a real local ESLint install and a config
  file (flat config or legacy). This wasn't previously tested end-to-end; confirmed now
  with a real violation caught through the LSP, not just via the CLI.

## [0.2.0]

### Added
- `auto-save.nvim` (`okuuva` fork — the original `Pocco81/auto-save.nvim` has been
  unmaintained since 2024-05) for RustRover-style background auto-save. Configured with
  `noautocmd = true` so debounced autosaves don't also trigger format-on-save; only a
  manual `:w`/`<leader>f` formats. Verified: an intentionally mis-formatted file survives
  an autosave untouched, then reformats correctly on manual save.
- Inline diagnostics styling: virtual text with gutter sign icons (``/``/``/``),
  underline, severity-sorted — matches the inline error-message style from JetBrains IDEs.
- Inlay type hints, auto-enabled on any LSP client that supports `textDocument/inlayHint`.
- Real-time clippy for Rust: `rust-analyzer.check.command = "clippy"`. Verified with a
  clippy-only lint (`needless_return`) that plain `cargo check` never flags.
- `--effort medium` for all 99/Claude Code requests, via 99's own `provider_extra_args`
  setup option (not a source patch, so it isn't lost on plugin updates).

### Changed
- `model` in `ninety-nine.lua`: `claude-sonnet-4-5` → `claude-sonnet-5`.
- `lua/config/plugins/lsp.lua` rewritten to use the native `vim.lsp.config()` /
  automatic `vim.lsp.enable()` flow instead of `mason-lspconfig`'s `handlers` option.

### Fixed
- **`mason-lspconfig`'s `handlers` API no longer exists in the installed version** — the
  custom `rust_analyzer`/`powershell_es` handlers from the original setup were silently
  never called; `mason-lspconfig` now installs servers and calls `vim.lsp.enable()`
  automatically on its own. Found by inspecting the actual installed plugin source, not
  assumed from older docs. Rewired capabilities/settings through `vim.lsp.config()`,
  which deep-merges with nvim-lspconfig's own per-server defaults instead of replacing
  them.

## [0.1.0] — initial commit

First push. Bootstrapped from scratch (inspired by, not cloned from, ThePrimeagen's
init.lua), scoped to Rust / Node+TypeScript / PowerShell / Flutter+Dart plus 99 on
Claude Code.

- lazy.nvim, Telescope, Treesitter + treesitter-context (lua, vim, vimdoc, query, rust,
  javascript, typescript, tsx, dart, powershell, json, markdown, bash)
- nvim-lspconfig + mason.nvim + mason-lspconfig, nvim-cmp stack, LuaSnip +
  friendly-snippets, conform.nvim
- Harpoon (`harpoon2` branch, local clone) and 99 (local clone), both from
  ThePrimeagen's repos
- undotree, vim-fugitive, trouble.nvim, fidget.nvim, zen-mode.nvim, cloak.nvim,
  rose-pine (single colorscheme)
- nvim-autopairs, toggleterm.nvim
- netrw tuned to match ThePrimeagen's own settings (`browse_split`, `banner`, `winsize`)
- Explicitly excluded: Go tooling, php.nvim, jai.vim, refactoring.nvim,
  cellular-automaton.nvim, brightburn.vim, golf, supermaven-nvim, nvim-dap
