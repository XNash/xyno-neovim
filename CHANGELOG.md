# Changelog

All notable changes to this config are documented here.

## [Unreleased]

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
