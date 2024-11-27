---@type LazySpec
return {
  "mfussenegger/nvim-jdtls",
  opts = function(_, opts)
    opts.cmd[1] = "/Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home/bin/java" -- specify compatible java binary
    return require("astrocore").extend_tbl(opts, {
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-1.8",
                path = "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home",
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
