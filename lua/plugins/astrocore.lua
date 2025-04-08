-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    filetypes = {
      extension = {
        gitconfig = "gitconfig",
      },
    },
    options = {
      opt = {
        iskeyword = vim.list_extend(vim.opt.iskeyword:get(), { "-" }),
        completeopt = { "menu", "menuone", "noselect", "fuzzy" },
      },
    },
    mappings = {
      n = {
        -- dap
        ["<Leader>df"] = { function() require("dap").focus_frame() end, desc = "Focus current execution point" },
        ["<Leader>dl"] = {
          function()
            require("dap").list_breakpoints(false)
            require("snacks").picker.qflist { title = "Breakpoints" }
          end,
          desc = "List breakpoints quickfix",
        },
        ["<Leader>dv"] = {
          function()
            local widgets = require "dap.ui.widgets"
            widgets.centered_float(widgets.scopes)
          end,
          desc = "Inspect variables in popup",
        },

        -- miscellaneous
        ["<Leader>xc"] = { "<cmd>cclose<cr>", desc = "Close quickfix window" },
        ["<Leader>W"] = { "<cmd>wall<cr>", desc = "Save all" },
        ["<Leader>z"] = { "<cmd>tab split<cr>", desc = "Open in new tab" },
        ["g]"] = { "<C-]>", desc = "Go to tag" },
        ["<Leader>bh"] = {
          function() require("astrocore.buffer").close_left() end,
          desc = "Close all buffers to the left",
        },
        ["<Leader>bl"] = {
          function() require("astrocore.buffer").close_right() end,
          desc = "Close all buffers to the right",
        },
        ["<Leader>br"] = false,
        ["<Leader>c"] = { function() require("astrocore.buffer").close() end, desc = "Delete buffer" },
        ["<Leader>C"] = { "<cmd>tabc<cr>", desc = "Close tab" },
        ["<Leader>o"] = { "<cmd>only<cr>", desc = "Close all other windows" },
        ["<Leader>O"] = { "<cmd>tabo<cr>", desc = "Close all other tabs" },
      },
      c = {
        ["<C-a>"] = { "<Home>", desc = "Move cursor to beginning of line" },
        ["<C-e>"] = { "<End>", desc = "Move cursor to end of line" },
        ["<C-b>"] = { "<Left>", desc = "Move cursor one char back" },
        ["<C-f>"] = { "<Right>", desc = "Move cursor one char forward" },
        ["<M-b>"] = { "<S-Left>", desc = "Move cursor one word back" },
        ["<M-f>"] = { "<S-Right>", desc = "Move cursor one word forward" },
        ["<C-d>"] = { "<Del>", desc = "Delete one char forward" },
      },
    },
  },
}
