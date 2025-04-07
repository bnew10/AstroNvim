if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

---@type LazySpec
return {
  "willothy/flatten.nvim",
  dependencies = {
    {
      "AstroNvim/astrocore",
      ---@type AstroCoreOpts
      opts = {
        autocmds = {
          nvimremote = {
            {
              event = "VimEnter",
              desc = "Create nvim remote host file",
              once = true,
              callback = function(opts)
                -- local
                -- local pid = vim.fn.getpid()
                -- local nvim_host_sock = vim.fn.stdpath "run" .. "/../nvim_host"
                -- if not vim.uv.fs_stat(nvim_host) then
                --   vim.fn.writefile({ vim.v.servername }, nvim_host)
                -- end
              end,
            },
          },
        },
      },
    },
  },
  opts = {
    window = {
      open = "alternate",
    },
    hooks = {
      pipe_path = function()
        -- If running in a terminal inside Neovim:
        if vim.env.NVIM then return vim.env.NVIM end
      end,
    },
  },
  lazy = false,
  priority = 99999,
}
