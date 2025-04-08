---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  ---@module "yazi"
  dependencies = {
    "folke/snacks.nvim",
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<Leader>y"] = { "<cmd>Yazi<cr>", desc = "Yazi" }
      end,
    },
  },
  cmd = "Yazi",
  ---@type YaziConfig
  opts = {
    open_for_directories = false,
    keymaps = {
      show_help = "<f1>",
      cycle_open_buffers = "<a-tab>",
      grep_in_directory = false,
    },
  },
}
