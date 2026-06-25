---@type LazySpec
return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  -- This will provide type hinting with LuaLS
  ---@module "conform"
  ---@type conform.setupOpts
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { "prettierd" },
      yaml = { "prettierd" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "prefer",
      stop_after_first = true,
    },
    -- Format on save, except for these filetypes. lsp_format = "fallback" lets
    -- filetypes without a conform formatter (e.g. swift) still format via LSP.
    format_on_save = function(bufnr)
      local ignore = { java = true, javascript = true, xml = true, css = true }
      if ignore[vim.bo[bufnr].filetype] then return end
      return { lsp_format = "fallback" }
    end,
    -- Customize formatters
    formatters = {
      shfmt = {
        append_args = { "-i", "2" },
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
}
