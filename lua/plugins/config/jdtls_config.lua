return function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local root_dir = vim.fs.root(0, { ".git", "mvnw", "pom.xml" }) or vim.fs.dirname(buf_name)
  local project_name = vim.fs.basename(vim.fs.dirname(buf_name) == root_dir and buf_name or root_dir)
  local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name

  -- Build bundles list for debug adapter and test runner
  local bundles = {
    vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
  }
  vim.list_extend(bundles, vim.split(vim.fn.glob("$MASON/share/java-test/*.jar", true), "\n", { trimempty = true }))

  local config = {
    name = "jdtls",

    cmd = {
      vim.fn.expand "$MASON/bin/jdtls",
      "--java-executable",
      "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/bin/java",
      "-configuration",
      vim.fn.expand "$MASON/share/jdtls/config/arm",
      "-data",
      workspace_dir,
    },

    root_dir = root_dir,

    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    settings = {
      java = {
        eclipse = { downloadSources = true },
        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = {
            {
              name = "JavaSE-1.8",
              path = "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home",
              default = true,
            },
            {
              name = "JavaSE-21",
              path = "/Library/Java/JavaVirtualMachines/openjdk-21.jdk/Contents/Home",
            },
          },
        },
        maven = { downloadSources = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        inlayHints = { parameterNames = { enabled = "all" } },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      },
    },

    init_options = {
      bundles = bundles,
    },

    on_attach = function(...)
      local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
      if astrolsp_avail then astrolsp.on_attach(...) end
    end,
  }
  require("jdtls").start_or_attach(config, { dap = { hotcodereplace = "auto" } })
end
