local root_dir = (function()
  for _, marker in ipairs { ".git", "pom.xml" } do
    local dir = vim.fs.root(0, marker)
    if dir ~= nil then return dir end
  end
  return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
end)()

local project_name = (function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  if vim.fs.dirname(buf_name) == root_dir then
    return vim.fs.basename(buf_name)
  else
    return vim.fs.basename(root_dir)
  end
end)()

local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name

-- See `:help vim.lsp.start` for an overview of the supported `config` options.
local config = {
  name = "jdtls",

  -- `cmd` defines the executable to launch eclipse.jdt.ls.
  -- `jdtls` must be available in $PATH and you must have Python3.9 for this to work.
  --
  -- As alternative you could also avoid the `jdtls` wrapper and launch
  -- eclipse.jdt.ls via the `java` executable
  -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
  -- cmd = {
  --   "jdtls",
  --   "--java-executable",
  --   "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/bin/java",
  --   "-data",
  --   workspace_dir,
  -- },
  cmd = {
    "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/bin/java",
    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.level=ALL",
    "-Xms1G",
    "-Xmx1G",
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",
    "-jar",
    vim.fn.expand "$MASON/share/jdtls/plugins/org.eclipse.equinox.launcher.jar",
    "-configuration",
    vim.fn.expand "$MASON/share/jdtls/config/arm",
    "-data",
    workspace_dir,
  },

  -- `root_dir` must point to the root of your project.
  -- See `:help vim.fs.root`
  root_dir = root_dir,

  -- Here you can configure eclipse.jdt.ls specific settings
  -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  -- for a list of options
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

  -- This sets the `initializationOptions` sent to the language server
  -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
  -- you'll need to set the `bundles`
  --
  -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
  --
  -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
  init_options = {
    bundles = {
      vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
      -- unpack remaining bundles
      (table.unpack or unpack)(vim.split(vim.fn.glob "$MASON/share/java-test/*.jar", "\n", {})),
    },
  },

  on_attach = function(...)
    local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
    if astrolsp_avail then astrolsp.on_attach(...) end
  end,
}
require("jdtls").start_or_attach(config, { dap = { hotcodereplace = "auto" } })
