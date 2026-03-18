---@type LazySpec
return {
  "nvim-neo-tree/neo-tree.nvim",
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        local prefix = "<Leader>n"

        maps.n[prefix] = { desc = require("astroui").get_icon("FolderOpen", 1, true) .. "Neo-tree" }

        maps.n[prefix .. "n"] = { function() vim.cmd.Neotree "focus" end, desc = "Focus" }
        maps.n[prefix .. "c"] = { function() vim.cmd.Neotree "close" end, desc = "Close" }
      end,
    },
  },
  ---@module "neo-tree"
  ---@type neotree.Config
  opts = {
    window = {
      mappings = {
        ["<C-x>"] = "open_split",
        ["<C-v>"] = "open_vsplit",
      },
    },
    event_handlers = {
      { event = "file_opened", handler = function() require("neo-tree.command").execute { action = "close" } end },
    },
  },
}
