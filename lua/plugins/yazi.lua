---@type LazySpec
return {
  "mikavilpas/yazi.nvim",
  ---@module "yazi"
  dependencies = {
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
    -- yazi_floating_window_border = "none",
    future_features = {
      ya_emit_reveal = true,
      ya_emit_open = true,
    },
  },
}
