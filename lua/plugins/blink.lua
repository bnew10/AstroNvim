---@type LazySpec
return {
  "Saghen/blink.cmp",
  ---@module "blink-cmp"
  ---@type blink.cmp.Config
  opts = {
    cmdline = {
      completion = {
        list = {
          selection = {
            preselect = false,
          },
        },
      },
      keymap = {
        ["<C-e>"] = {},
        ["<C-h>"] = { "cancel", "fallback" },
      },
    },
  },
}
