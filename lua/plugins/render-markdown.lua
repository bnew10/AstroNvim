---@type LazySpec
return {
  "MeanderingProgrammer/render-markdown.nvim",
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {
    overrides = {
      buftype = {
        nofile = {
          win_options = {
            concealcursor = {
              rendered = "nvic",
            },
          },
        },
      },
    },
  },
}
