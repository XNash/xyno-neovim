# Changelog

All notable changes to this config are documented here.

## [Unreleased]

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
