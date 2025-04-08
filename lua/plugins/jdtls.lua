---@type LazySpec
return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    local util = require "lspconfig.util"
    local cmd = assert(opts.cmd)
    local root_files = {
      -- Multi-module projects
      { ".git", "build.gradle", "build.gradle.kts" },
      -- Single-module projects
      {
        "build.xml", -- Ant
        "pom.xml", -- Maven
        "settings.gradle", -- Gradle
        "settings.gradle.kts", -- Gradle
      },
    }
    for _, patterns in ipairs(root_files) do
      local root = util.root_pattern(unpack(patterns))(vim.api.nvim_buf_get_name(0))
      if root then
        opts.root_dir = root
        break
      end
    end
    local project_name = vim.fs.basename(opts.root_dir)
    local workspace_dir = vim.fn.stdpath "data" .. "/site/java/workspace-root/" .. project_name
    vim.fn.delete(cmd[#cmd], "d") -- delete erroneously made workspace folder if it's empty/not being used
    vim.fn.mkdir(workspace_dir, "p")
    cmd[1] = "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/bin/java" -- specify compatible java binary
    cmd[#cmd] = workspace_dir -- correctly calculated workspace folder
    return require("astrocore").extend_tbl(opts, {
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home",
                default = true,
              },
              {
                name = "JavaSE-23",
                path = "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home",
              },
            },
          },
        },
        format = {
          enabled = true,
          settings = { -- you can use your preferred format style
            url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
            profile = "GoogleStyle",
          },
        },
      },
    })
  end,
}
