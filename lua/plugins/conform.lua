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
      markdown = { "prettierd" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "prefer",
      stop_after_first = true,
    },
    -- Format on save, except for these filetypes. lsp_format = "fallback" lets
    -- filetypes without a conform formatter (e.g. swift) still format via LSP.
    format_on_save = function(bufnr)
      if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
      local ignore = { java = true, javascript = true, xml = true, css = true }
      if ignore[vim.bo[bufnr].filetype] then return end
      return { lsp_format = "fallback" }
    end,
    -- Customize formatters
    formatters = {
      shfmt = {
        append_args = { "-i", "2" },
      },
      -- Hard-wrap markdown prose at column 190. prose-wrap=always enables
      -- wrapping (prettier's default "preserve" inserts none); scoped to
      -- markdown so js/yaml keep prettier's default print width.
      prettierd = {
        prepend_args = function(_, ctx)
          if vim.bo[ctx.buf].filetype == "markdown" then return { "--print-width=190", "--prose-wrap=always" } end
          return {}
        end,
      },
    },
  },
  init = function()
    -- If you want the formatexpr, here is the place to set it
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
  specs = {
    -- Replaces AstroLSP's LSP-gated <Leader>uf/uF toggles, which conform's format_on_save never reads.
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)

        maps.n["<Leader>uf"] = {
          function()
            vim.b.disable_autoformat = not vim.b.disable_autoformat
            vim.notify("Buffer autoformatting " .. (vim.b.disable_autoformat and "off" or "on"))
          end,
          desc = "Toggle autoformatting (buffer)",
        }

        maps.n["<Leader>uF"] = {
          function()
            vim.g.disable_autoformat = not vim.g.disable_autoformat
            vim.notify("Global autoformatting " .. (vim.g.disable_autoformat and "off" or "on"))
          end,
          desc = "Toggle autoformatting (global)",
        }
      end,
    },
    {
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      optional = true,
      -- Only prettierd: stylua, isort, black, and shfmt are already ensured by
      -- the astrocommunity lua/python/bash packs imported in lua/community.lua.
      opts = function(_, opts)
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "prettierd" })
      end,
    },
  },
}
