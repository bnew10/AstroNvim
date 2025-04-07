-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.go" },
  -- { import = "astrocommunity.pack.sql" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.java" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.motion.leap-nvim" },
  { import = "astrocommunity.utility.lua-json5" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.completion.avante-nvim" },
  { import = "astrocommunity.fuzzy-finder.telescope-nvim" },
  -- { import = "astrocommunity.debugging.nvim-dap-virtual-text" },
  { import = "astrocommunity.recipes.astrolsp-no-insert-inlay-hints" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  -- import/override with your plugins folder
}
