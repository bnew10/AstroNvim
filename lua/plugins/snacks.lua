---@type LazySpec
return {
  "folke/snacks.nvim",
  ---@type snacks.Config
  opts = {
    picker = {
      win = {
        input = {
          keys = {
            ["<c-u>"] = { "<c-s-u>", mode = { "i" }, expr = true, desc = "clear" },
          },
        },
      },
    },
  },
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        maps.n["<Leader>fb"] =
          { function() require("snacks").picker.buffers { hidden = true } end, desc = "Find buffers" }
        maps.n["<Leader>fo"] = {
          function() require("snacks").picker.recent { filter = { cwd = true } } end,
          desc = "Find recent files (cwd)",
        }
        maps.n["<Leader>fO"] = { function() require("snacks").picker.recent() end, desc = "Find recent files" }
        maps.n["<Leader>fw"] = {
          function()
            require("snacks").picker.grep {
              args = {
                "--hidden",
                "--no-ignore-exclude",
                "--no-ignore-global",
                "--no-ignore-parent",
                "--no-ignore-vcs",
              },
            }
          end,
          desc = "Find words",
        }
        maps.n["<Leader>fW"] = {
          function() require("snacks").picker.grep_buffers { args = { "--hidden", "--no-ignore" }, need_search = true } end,
          desc = "Find words in open files",
        }
      end,
    },
  },
}
