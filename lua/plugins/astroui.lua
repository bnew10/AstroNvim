-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    status = {
      attributes = {
        buffer_active = { bold = true, italic = false, underline = true, force = true },
        -- buffer_active = { bold = true, italic = false },
      },
      colors = {
        -- buffer_active_fg = "#ebae34",
        -- buffer_active_sp = "#ebae34",
      },
    },
  },
}
