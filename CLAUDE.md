# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is an AstroNvim v6 user configuration. It is used across a mixed fleet — arm64 and x86_64 macOS plus Debian-family Linux — so nothing here may hardcode an Apple Silicon path; probe instead (see JDTLS below). It uses lazy.nvim for plugin management with `<Space>` as leader and `,` as localleader.

## Linting and Formatting

- **Lua linting:** `selene` (configured in `selene.toml`, std = neovim)
- **Lua formatting:** `stylua` (via conform.nvim). Run `:ConformInfo` to check formatter status
- Format-on-save is enabled globally except for java, javascript, xml, and css filetypes
- CLI checks (before committing): `selene lua/ tests/` (lint), `stylua --check lua/ tests/` (format check)

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
- `tests/` — standalone `nvim -l tests/<name>.lua` scripts (no framework). `jdtls_probes_test.lua` `load()`s the real helper chunk out of `jdtls_config.lua` rather than copying it, so it cannot drift from the code it tests

### JDTLS (Java)

Java LSP is handled entirely by nvim-jdtls, not mason-lspconfig. The active config is `lua/plugins/config/jdtls_config.lua` which uses a `~/.local/bin/jdtls` wrapper script for the cmd (absolute path, because Mason prepends its own `bin/` to PATH inside Neovim). `ftplugin/off-java.lua` is an older inline version (not loaded). JDTLS formatting is disabled; jdtls is excluded from mason-lspconfig's automatic_enable.

`settings.java.configuration.runtimes` is **probed at FileType-java time, never hardcoded** — the same config runs on arm64/x86_64 macOS and on Linux, and brew's `openjdk@8` pins `depends_on arch: :x86_64` on macOS, so on Apple Silicon it *errors* rather than merely lacking a bottle (Java 8 comes from the `zulu@8` cask, a manual step outside converge because its `.pkg` needs sudo). Each entry is included only if found:

- **JavaSE-1.8** (`default = true` when present): `vim.env.JAVA_HOME` first — exported by `~/.java_env`, which the managed `~/.zshrc` sources — but only after confirming it is really a JDK 8, since it is user env that may point at any version and a wrong *default* runtime silently type-checks Java 8 code against newer semantics. Then macOS `/usr/libexec/java_home -v 1.8.0` and a scan of `/Library/Java/JavaVirtualMachines/*/Contents/Home`, else Linux linuxbrew `openjdk@8/libexec` and `/usr/lib/jvm/java-8-openjdk-*`. On macOS a candidate must pass **both** tests — executable `bin/javac` *and* a `release` file saying `JAVA_VERSION="1.8` — because `java_home` lies in two directions: it **never fails** (an unmatched `-v` prints the newest JDK and exits 0, so its return code is dead weight and `-v 1.8` would hand back JDK 21 on a box with no Java 8 — hence `-v 1.8.0`, the prefix every real JDK 8 uses), and it ranks the browser applet-plugin JRE (`1.8.441.07`) above a real JDK 8 (`1.8.0_441`) while that JRE ships a `release` claiming 1.8 and no compiler. The `/Library/Java` scan is what still finds the real Oracle/Zulu install when the applet plugin outranks it and `JAVA_HOME` is unset (GUI Neovim, launched without a login shell). Linux needs neither test, its candidate paths are version-pinned already. Nothing found → a `vim.notify` WARN, because the fallback (jdt.ls's own 21+ JDK) is otherwise invisible.
- Both finders are **memoized module-locally** (`resolve_jdks`): the module body runs per `FileType java` buffer, so an unmemoized probe would fork `java_home` for every Java file opened and re-fire the WARN each time. The WARN therefore lands at most once per session. `tests/jdtls_probes_test.lua` covers all of this.
- **JavaSE-21**: keg-only `openjdk@21` under `$HOMEBREW_PREFIX`, `/opt/homebrew`, `/usr/local`, `/home/linuxbrew/.linuxbrew` — macOS layout (`libexec/openjdk.jdk/Contents/Home`) then Linux (`libexec`). `HOMEBREW_PREFIX` is only exported by interactive shells, so it is absent for GUI/agent-spawned Neovim and must be treated as optional.

### Picker

Snacks.nvim is the picker (not Telescope). LSP navigation (references, definitions, implementations, declarations) uses `snacks.picker.lsp_*` with ivy layout. File/grep pickers include `--hidden` and `--no-ignore-vcs` flags by default.

### Local plugin development

`lazy.nvim` dev path is `~/repos` — plugins with `dev = true` are loaded from there.

### Notable custom modules

- `lua/strike.lua` — visual selection strikethrough toggle (currently disabled in init.lua, mapped to `gs` in visual mode in astrocore)
- `lua/polish.lua` — sets up global helpers: `_G.inspect()` and `_G.log()` (both delegate to snacks.debug), `_G.popts()` for reading plugin opts
