---@type LazySpec
return {
  "polirritmico/telescope-lazy-plugins.nvim",
  lazy = true,
  dependencies = {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = assert(opts.mappings)
      maps.n["<Leader>pc"] =
        { function() require("telescope").extensions.lazy_plugins.lazy_plugins() end, desc = "Plugins Config" }
    end,
  },
  config = function()
    require("astrocore").on_load("telescope.nvim", function() require("telescope").load_extension "lazy_plugins" end)
  end,
}
