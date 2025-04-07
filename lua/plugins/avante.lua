---@type LazySpec
return {
  "yetone/avante.nvim",
  ---@module "avante"
  ---@type avante.Config
  ---@diagnostic disable: missing-fields
  opts = {
    cursor_applying_provider = "claude",
    behaviour = {
      enable_cursor_planning_mode = true,
    },
  },
}
