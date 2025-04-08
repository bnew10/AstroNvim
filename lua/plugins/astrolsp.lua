-- AstroLSP allows you to customize the features in AstroNvim's LSP configuration engine
-- Configuration documentation can be found with `:h astrolsp`

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    formatting = {
      format_on_save = {
        ignore_filetypes = {
          "java",
          "xml",
        },
      },
    },
    mappings = {
      n = {
        grr = {
          function()
            require("snacks").picker.lsp_references {
              include_declaration = false,
              include_current = true,
            }
          end,
          desc = "Search references",
          cond = "textDocument/references",
        },
        gri = {
          function()
            require("snacks").picker.lsp_implementations {
              include_current = true,
            }
          end,
          desc = "Search implementations",
          cond = "textDocument/implementation",
        },
        gd = {
          function()
            require("snacks").picker.lsp_definitions {
              include_current = true,
            }
          end,
          desc = "Search definitions",
          cond = "textDocument/definition",
        },
        gD = {
          function()
            require("snacks").picker.lsp_declarations {
              include_current = true,
            }
          end,
          desc = "Search declarations",
          cond = "textDocument/declaration",
        },
      },
    },
  },
}
