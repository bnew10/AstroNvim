---@type LazySpec
return {
  "folke/snacks.nvim",
  dev = true,
  branch = "jump_center_field",
  opts = function(_, opts)
    local get_icon = require("astroui").get_icon

    opts.dashboard.preset.keys = {
      opts.dashboard.preset.keys[1],
      opts.dashboard.preset.keys[2],
      opts.dashboard.preset.keys[3],
      opts.dashboard.preset.keys[4],
      { key = "s", action = "<Leader>S.", icon = get_icon("Refresh", 0, true), desc = "Load Last Dirsession  " },
      { key = "p", action = "<Leader>pa", icon = get_icon("Package", 0, true), desc = "Update Lazy and Mason  " },
      { key = "g", action = "<Leader>gg", icon = get_icon("Git", 0, true), desc = "Lazygit  " },
      { key = "y", action = "<Leader>y", icon = get_icon("FolderOpen", 0, true), desc = "Yazi  " },
    }

    opts.picker = {
      jump = { post_cmd = "norm! zv" },
      win = {
        input = {
          keys = {
            ["<c-u>"] = { "<c-s-u>", mode = { "i" }, expr = true, desc = "clear" },
          },
        },
      },
    }
  end,
  specs = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)

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

        maps.n["<Leader>ff"] = {
          function() require("snacks").picker.files { hidden = true, cmd = "rg", args = { "--no-ignore-vcs" } } end,
          desc = "Find files",
        }

        maps.n["<Leader>fk"] =
          { function() require("snacks").picker.keymaps { plugs = true } end, desc = "Find keymaps" }

        -- maps.n["<Leader>f<CR>"] = {
        --   function()
        --     require("snacks").picker.resume {
        --       -- focus = "list",
        --       on_show = function(picker)
        --         require("snacks").debug.inspect(picker)
        --         require("snacks").debug.inspect(picker.opts.source)
        --       end,
        --     }
        --   end,
        --   desc = "Resume previous search",
        -- }

        maps.n["<Leader>ls"] = {
          function()
            local aerial_avail, aerial = pcall(require, "aerial")
            if aerial_avail and aerial.snacks_picker then
              aerial.snacks_picker { jump = { post_cmd = "norm! zt" } }
            else
              require("snacks").picker.lsp_symbols()
            end
          end,
          desc = "Search symbols",
        }
      end,
    },
  },
}
