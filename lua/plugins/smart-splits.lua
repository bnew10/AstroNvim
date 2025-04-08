---@type LazySpec
return {
  "mrjones2014/smart-splits.nvim",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<C-h>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" }
        maps.n["<C-j>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" }
        maps.n["<C-k>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" }
        maps.n["<C-l>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" }
        maps.n["<C-\\>"] =
          { function() require("smart-splits").move_cursor_previous() end, desc = "Move to last split" }

        maps.n["<M-h>"] = { function() require("smart-splits").resize_left() end, desc = "Resize split left" }
        maps.n["<M-j>"] = { function() require("smart-splits").resize_down() end, desc = "Resize split down" }
        maps.n["<M-k>"] = { function() require("smart-splits").resize_up() end, desc = "Resize split up" }
        maps.n["<M-l>"] = { function() require("smart-splits").resize_right() end, desc = "Resize split right" }

        maps.n["<M-H>"] = { function() require("smart-splits").swap_buf_left() end, desc = "Swap split left" }
        maps.n["<M-J>"] = { function() require("smart-splits").swap_buf_down() end, desc = "Swap split down" }
        maps.n["<M-K>"] = { function() require("smart-splits").swap_buf_up() end, desc = "Swap split up" }
        maps.n["<M-L>"] = { function() require("smart-splits").swap_buf_right() end, desc = "Swap split right" }
      end,
    },
  },
}
