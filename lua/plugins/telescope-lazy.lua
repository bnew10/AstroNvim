---@type LazySpec
return {
  "tsakirist/telescope-lazy.nvim",
  lazy = true,
  dependencies = {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = assert(opts.mappings)
      maps.n["<Leader>pr"] = { function() require("telescope").extensions.lazy.lazy() end, desc = "Plugins README" }
    end,
  },
  config = function()
    require("astrocore").on_load("telescope.nvim", function() require("telescope").load_extension "lazy" end)
  end,
}
