# xyno-neovim

A minimal, from-scratch Neovim config — inspired by [ThePrimeagen's init.lua](https://github.com/ThePrimeagen/init.lua)
(same infra-level plugin choices, same leader key convention) but scoped only to what's
actually needed: Rust, Node/TypeScript, PowerShell, Flutter/Dart, plus AI via
[99](https://github.com/ThePrimeagen/99) on Claude Code.

## Structure

- `init.lua` — leader key, loads options/lazy/keymaps
- `lua/config/options.lua` — editor options
- `lua/config/keymaps.lua` — non-plugin-specific keymaps
- `lua/config/lazy.lua` — lazy.nvim bootstrap
- `lua/config/plugins/*.lua` — one file per plugin or tightly related group

## Requirements

- Neovim 0.10+
- git, ripgrep, a C compiler (Treesitter parser builds)
- Node/npm, Rust (rustup), PowerShell, the Flutter SDK — for the respective language tooling
- The `claude` CLI, authenticated, for the 99 AI integration

## Local plugins

Two plugins are pulled from local clones rather than a git URL and expected at:

- `~/personal/harpoon` — [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon), `harpoon2` branch
- `~/personal/99` — [ThePrimeagen/99](https://github.com/ThePrimeagen/99)

Clone both before first launch.
