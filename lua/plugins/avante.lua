if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "yetone/avante.nvim",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = assert(opts.mappings)
        local prefix = "<Leader>ac"

        -- maps.n[prefix] = { desc = "Choose..." }

        -- maps.n[prefix .. "o"] = {}
      end,
    },
  },
}
