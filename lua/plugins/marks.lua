---@type LazySpec
return {
  "chentoast/marks.nvim",
  event = "User AstroFile",
  opts = {
    default_mappings = false,
    cyclic = false,
    excluded_filetypes = {
      "qf",
      "NvimTree",
      "toggleterm",
      "TelescopePrompt",
      "alpha",
      "netrw",
      "neo-tree",
    },
  },
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local utils = require "astrocore"
        local snacks = require "snacks"
        local maps = assert(opts.mappings)

        maps.n = utils.extend_tbl(maps.n, {
          ["m,"] = {
            function() require("marks").set_next() end,
            desc = "Set the next available alphabetical (lowercase) mark",
          },
          ["dm-"] = {
            function() require("marks").delete_line() end,
            desc = "Delete all marks on the current line",
          },
          ["dm<Space>"] = {
            function() require("marks").delete_buf() end,
            desc = "Delete all marks in the current buffer",
          },
          ["]o"] = {
            function() require("marks").next() end,
            desc = "Move to next mark",
          },
          ["[o"] = {
            function() require("marks").prev() end,
            desc = "Move to previous mark",
          },
          ["<Leader>f'"] = {
            function()
              require("marks").mark_state:buffer_to_list "quickfixlist"
              local items = vim.fn.getqflist({ items = true }).items
              items = vim.fn.sort(items, function(i1, i2) return i1.lnum - i2.lnum end)
              vim.fn.setqflist(items, "r")
              snacks.picker.qflist { title = "Local Marks", focus = "list", jump = { post_cmd = "norm! zt" } }
            end,
            desc = "Find local marks",
          },
        })
      end,
    },
  },
}
