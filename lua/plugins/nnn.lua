---@type LazySpec
return {
  "luukvbaal/nnn.nvim",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<Leader>n"] = { "<Cmd>NnnPicker %:p:h<CR>", desc = "Open nnn" }
      end,
    },
  },
  cmd = "NnnPicker",
  opts = {
    picker = {
      cmd = "nnn -HUx",
      style = {
        border = "rounded",
      },
    },
  },
}
