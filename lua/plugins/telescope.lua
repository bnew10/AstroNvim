---@type LazySpec
return {
  "nvim-telescope/telescope.nvim",
  specs = {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      local maps = opts.mappings
      maps.n["<Leader>fb"] = {
        function() require("telescope.builtin").buffers { sort_mru = true } end,
        desc = "Find buffers",
      }
      maps.n["<Leader>fo"] =
        { function() require("telescope.builtin").oldfiles { only_cwd = true } end, desc = "Find recent files in cwd" }
      maps.n["<Leader>fO"] = { function() require("telescope.builtin").oldfiles() end, desc = "Find recent files" }
      maps.n["<Leader>fw"] = {
        function()
          require("telescope.builtin").live_grep {
            additional_args = function(args)
              return vim.list_extend(args, {
                "--hidden",
                "--no-ignore-exclude",
                "--no-ignore-global",
                "--no-ignore-parent",
                "--no-ignore-vcs",
              })
              -- return vim.list_extend(args, { "--hidden", "--no-ignore", "--ignore-exclude" })
            end,
          }
        end,
        desc = "Find words",
      }
      maps.n["<Leader>fW"] = {
        function()
          require("telescope.builtin").live_grep {
            grep_open_files = true,
            additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
          }
        end,
        desc = "Find words in open files",
      }
    end,
  },
  dependencies = {
    { "polirritmico/telescope-lazy-plugins.nvim" },
    { "tsakirist/telescope-lazy.nvim" },
  },
  opts = {
    defaults = {
      mappings = {
        i = {
          ["<C-u>"] = false,
        },
      },
    },
    extensions = {
      ---@module "telescope._extensions.lazy_plugins"
      ---@type TelescopeLazyPluginsUserConfig
      lazy_plugins = {
        lazy_config = vim.fn.stdpath "config" .. "/lua/lazy_setup.lua",
      },
    },
  },
}
