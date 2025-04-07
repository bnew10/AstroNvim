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
    -- autocmds = {
    --   lsp_references = {
    --     cond = "textDocument/references",
    --     {
    --       event = "LspRequest",
    --       desc = "TEST",
    --       callback = function(args)
    --         local request = args.data.request
    --         if request.method == "textDocument/references" then vim.print(request) end
    --       end,
    --     },
    --   },
    -- },
  },
}
