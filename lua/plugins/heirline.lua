---@type LazySpec
return {
  "rebelot/heirline.nvim",
  specs = {
    {
      "AstroNvim/astrocore",
      ---@param opts AstroCoreOpts
      opts = function(_, opts)
        local maps = assert(opts.mappings)

        maps.n["<Leader>b\\"] = false
        maps.n["<Leader>bs"] = {
          function()
            require("astroui.status.heirline").buffer_picker(function(bufnr)
              vim.cmd.split()
              vim.api.nvim_win_set_buf(0, bufnr)
            end)
          end,
          desc = "Horizontal split buffer from tabline",
        }

        maps.n["<Leader>b|"] = false
        maps.n["<Leader>bv"] = {
          function()
            require("astroui.status.heirline").buffer_picker(function(bufnr)
              vim.cmd.vsplit()
              vim.api.nvim_win_set_buf(0, bufnr)
            end)
          end,
          desc = "Vertical split buffer from tabline",
        }
      end,
    },
  },
}
