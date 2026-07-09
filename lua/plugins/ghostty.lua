---@type LazySpec
return {
  dir = (vim.env.GHOSTTY_RESOURCES_DIR or "") .. "/../nvim/site",
  name = "ghostty",
  lazy = false,
  cond = vim.env.GHOSTTY_RESOURCES_DIR ~= nil,
}
