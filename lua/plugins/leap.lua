---@type LazySpec
return {
  "ggandor/leap.nvim",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)

        maps.n["gs"] = false
        maps.n["ga"] = { function() require("leap.treesitter").select() end, desc = "Leap treesitter" }
        maps.n["gA"] = { 'V<cmd>lua require("leap.treesitter").select()<cr>', desc = "Leap treesitter linewise" }
        maps.n["s"] = { "<Plug>(leap)", desc = "Leap" }
        maps.n["S"] = { "<Plug>(leap-from-window)", desc = "Leap from window" }

        maps.x["gs"] = false
        maps.x["ga"] = { function() require("leap.treesitter").select() end, desc = "Leap treesitter" }
        maps.x["gA"] = { 'V<cmd>lua require("leap.treesitter").select()<cr>', desc = "Leap treesitter linewise" }
        maps.x["s"] = { "<Plug>(leap)", desc = "Leap" }
        maps.x["S"] = { "<Plug>(leap-from-window)", desc = "Leap from window" }

        maps.o["gs"] = false
        maps.o["ga"] = { function() require("leap.treesitter").select() end, desc = "Leap treesitter" }
        maps.o["gA"] = { 'V<cmd>lua require("leap.treesitter").select()<cr>', desc = "Leap treesitter linewise" }
      end,
    },
  },
  config = function()
    require("leap.user").set_repeat_keys(
      "<enter>",
      "<backspace>",
      { relative_directions = true, modes = { "n", "x", "o" } }
    )
  end,
}
