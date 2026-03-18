-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.python" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.utility.lua-json5" },
  { import = "astrocommunity.motion.nvim-surround" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  -- import/override with your plugins folder
}
