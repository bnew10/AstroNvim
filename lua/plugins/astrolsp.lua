-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    native_lsp_config = true,
    servers = { "sourcekit", "clangd" },
    -- format-on-save is owned by conform.nvim (see lua/plugins/conform.lua)
    formatting = {
      format_on_save = false,
    },
    ---@diagnostic disable: missing-fields
    config = {
      sourcekit = {
        filetypes = { "swift" },
      },
      -- Only the rdma-reconstructed repo gets the in-container clangd (Linux/RDMA headers via
      -- scripts/clangd-rb in the repo); every other C/C++ project uses the normal host clangd.
      clangd = {
        cmd = function(dispatchers, config)
          local repo = "/Users/bnewton/repos/work/rdma-reconstructed"
          local in_repo = vim.startswith(config.root_dir or "", repo)
          local bin = in_repo and repo .. "/scripts/clangd-rb" or "clangd"
          return vim.lsp.rpc.start({ bin }, dispatchers, { cwd = config.cmd_cwd })
        end,
      },
      taplo = {
        root_markers = { { ".taplo.toml", "taplo.toml" }, ".git" },
      },
    },
    handlers = {
      eslint = false,
    },
    mappings = {
      n = {
        grr = {
          function()
            require("snacks").picker.lsp_references {
              include_declaration = false,
              include_current = true,
              focus = "list",
              layout = {
                preset = "ivy",
              },
            }
          end,
          desc = "Search references",
          cond = "textDocument/references",
        },
        gri = {
          function()
            require("snacks").picker.lsp_implementations {
              include_current = true,
              focus = "list",
              layout = {
                preset = "ivy",
              },
            }
          end,
          desc = "Search implementations",
          cond = "textDocument/implementation",
        },
        gd = {
          function()
            require("snacks").picker.lsp_definitions {
              include_current = true,
              focus = "list",
              layout = {
                preset = "ivy",
              },
            }
          end,
          desc = "Search definitions",
          cond = "textDocument/definition",
        },
        gD = {
          function()
            require("snacks").picker.lsp_declarations {
              include_current = true,
              focus = "list",
              layout = {
                preset = "ivy",
              },
            }
          end,
          desc = "Search declarations",
          cond = "textDocument/declaration",
        },
      },
    },
  },
}
