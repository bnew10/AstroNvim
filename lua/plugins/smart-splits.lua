---@type LazySpec
return {
  -- Same name as AstroNvim's spec, so this merges into it and overrides its snapshot's `^2` pin.
  "smart-splits-nvim/smart-splits.nvim",
  version = "^3.0.0",
  lazy = true,
  dependencies = {
    {
      "bnew10/backend-rex",
      -- Load the checkout at lazy's dev path when this machine has one, else clone from GitHub
      -- (lazy_setup.lua sets dev.fallback = false, so dev must be false where the checkout is missing).
      dev = vim.fn.isdirectory(vim.fn.expand "~/repos/backend-rex") == 1,
    },
  },
  opts = {
    -- No warning where the backend detects no Rex pane: this config also runs outside Rex.
    mux = { backend = "smart-splits-backend-rex", warn_if_unusable = false },
    move = { at_edge = "stop" }, -- no wrap at a Rex edge, as ~/.config/rex/keys.lua chooses
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<C-H>"] = { function() require("smart-splits").move_cursor_left() end, desc = "Move to left split" }
        maps.n["<C-J>"] = { function() require("smart-splits").move_cursor_down() end, desc = "Move to below split" }
        maps.n["<C-K>"] = { function() require("smart-splits").move_cursor_up() end, desc = "Move to above split" }
        maps.n["<C-L>"] = { function() require("smart-splits").move_cursor_right() end, desc = "Move to right split" }
        -- v3 dropped move_cursor_previous; it only ever went back to the previous Neovim window
        maps.n["<C-\\>"] = { "<Cmd>silent! wincmd p<CR>", desc = "Move to last split" }

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
