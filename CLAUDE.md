# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an AstroNvim v6 user configuration on macOS (Apple Silicon). It uses lazy.nvim for plugin management with `<Space>` as leader and `,` as localleader.

## Linting and Formatting

- **Lua linting:** `selene` (configured in `selene.toml`, std = neovim)
- **Lua formatting:** `stylua` (via conform.nvim). Run `:ConformInfo` to check formatter status
- Format-on-save is enabled globally except for java, javascript, xml, and css filetypes

## Architecture

### Boot sequence

`init.lua` → `lua/lazy_setup.lua` (lazy.nvim setup) → `lua/community.lua` (AstroCommunity packs) → `lua/plugins/` (user plugins) → `lua/polish.lua` (final runtime setup)

### Plugin spec conventions

- Each file in `lua/plugins/` returns a `LazySpec` table for a single plugin or plugin group
- Keymaps are defined inside plugin specs via `astrocore` `opts.mappings` — not in a central keymaps file. To find a mapping, grep for the key sequence across `lua/plugins/`
- Some plugins use a `specs` key to co-configure other plugins (e.g., snacks.lua adds mappings via an astrocore spec)

### Key directories

- `lua/plugins/config/` — extracted config modules (currently `jdtls_config.lua` for Java LSP)
- `lua/lsp/` — native `vim.lsp.Config` tables loaded by Neovim's built-in LSP framework (not lspconfig). Files here are named after the LSP server
- `ftplugin/` — filetype-specific settings (e.g., `sql.lua` sets `formatprg`)

### JDTLS (Java)

Java LSP is handled entirely by nvim-jdtls, not mason-lspconfig. The active config is `lua/plugins/config/jdtls_config.lua` which uses a `~/.local/bin/jdtls` wrapper script for the cmd. `ftplugin/off-java.lua` is an older inline version (not loaded). JDTLS formatting is disabled; jdtls is excluded from mason-lspconfig's automatic_enable.

### Picker

Snacks.nvim is the picker (not Telescope). LSP navigation (references, definitions, implementations, declarations) uses `snacks.picker.lsp_*` with ivy layout. File/grep pickers include `--hidden` and `--no-ignore-vcs` flags by default.

### Local plugin development

`lazy.nvim` dev path is `~/repos` — plugins with `dev = true` are loaded from there.

### Notable custom modules

- `lua/strike.lua` — visual selection strikethrough toggle (currently disabled in init.lua, mapped to `gs` in visual mode in astrocore)
- `lua/polish.lua` — sets up global helpers: `_G.inspect()` and `_G.log()` (both delegate to snacks.debug), `_G.popts()` for reading plugin opts
