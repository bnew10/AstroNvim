---@type LazySpec
return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    dependencies = {
      "mfussenegger/nvim-dap",
      {
        "AstroNvim/astrolsp",
        optional = true,
        ---@type AstroLSPOpts
        opts = {
          ---@diagnostic disable: missing-fields
          formatting = {
            disabled = {
              "jdtls",
            },
          },
          handlers = { jdtls = false },
        },
      },
      {
        "JavaHello/spring-boot.nvim",
        cond = false,
        specs = {
          {
            "mfussenegger/nvim-jdtls",
            opts = function(_, opts)
              if not opts.init_options then opts.init_options = {} end
              if not opts.init_options.bundles then opts.init_options.bundles = {} end
              vim.list_extend(opts.init_options.bundles, require("spring_boot").java_extensions())
            end,
          },
        },
        opts = {},
      },
      { import = "astrocommunity.pack.xml" },
      {
        "nvim-treesitter/nvim-treesitter",
        optional = true,
        opts = function(_, opts)
          if opts.ensure_installed ~= "all" then
            opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "java" })
          end
        end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        optional = true,
        opts = function(_, opts)
          opts.automatic_enable = opts.automatic_enable or {}
          opts.automatic_enable.exclude = { "jdtls" }
        end,
      },
      {
        "jay-babu/mason-nvim-dap.nvim",
        optional = true,
        opts = function(_, opts)
          opts.ensure_installed =
            require("astrocore").list_insert_unique(opts.ensure_installed, { "javadbg", "javatest" })
        end,
      },
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        optional = true,
        opts = function(_, opts)
          opts.ensure_installed = require("astrocore").list_insert_unique(
            opts.ensure_installed,
            { "jdtls", "java-debug-adapter", "java-test", "vscode-spring-boot-tools" }
          )
        end,
      },
    },
    config = function(_, _)
      local jdtls_setup = require "plugins.config.jdtls_config"
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "java",
        callback = function() jdtls_setup() end,
      })
      jdtls_setup()
    end,
  },
}
