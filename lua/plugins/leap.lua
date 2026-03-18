---@type LazySpec
return {
  url = "https://codeberg.org/andyg/leap.nvim",
  event = "User AstroFile",
  dependencies = {
    "tpope/vim-repeat",
    {
      "AstroNvim/astrocore",
      ---@type AstroCoreOpts
      opts = {
        mappings = {
          n = {
            ["s"] = { "<Plug>(leap)", desc = "Leap" },
            ["S"] = { "<Plug>(leap-from-window)", desc = "Leap from window" },
            ["ga"] = { function() require("leap.treesitter").select() end, desc = "Leap treesitter" },
            ["gA"] = { 'V<cmd>lua require("leap.treesitter").select()<cr>', desc = "Leap treesitter linewise" },
          },
          x = {
            ["s"] = { "<Plug>(leap)", desc = "Leap" },
            ["S"] = { "<Plug>(leap-from-window)", desc = "Leap from window" },
            ["ga"] = { function() require("leap.treesitter").select() end, desc = "Leap treesitter" },
            ["gA"] = { 'V<cmd>lua require("leap.treesitter").select()<cr>', desc = "Leap treesitter linewise" },
          },
          o = {
            ["s"] = { "<Plug>(leap)", desc = "Leap" },
            ["S"] = { "<Plug>(leap-from-window)", desc = "Leap from window" },
            ["ga"] = { function() require("leap.treesitter").select() end, desc = "Leap treesitter" },
            ["gA"] = { 'V<cmd>lua require("leap.treesitter").select()<cr>', desc = "Leap treesitter linewise" },
          },
        },
      },
    },
  },
  opts = {},
  config = function()
    require("leap.user").set_repeat_keys(
      "<enter>",
      "<backspace>",
      { relative_directions = true, modes = { "n", "x", "o" } }
    )

    vim.api.nvim_create_autocmd("CmdlineLeave", {
      group = vim.api.nvim_create_augroup("LeapOnSearch", {}),
      callback = function()
        local ev = vim.v.event
        local is_search_cmd = (ev.cmdtype == "/") or (ev.cmdtype == "?")
        local cnt = vim.fn.searchcount().total

        if is_search_cmd and not ev.abort and (cnt > 1) then
          -- Allow CmdLineLeave-related chores to be completed before
          -- invoking Leap.
          vim.schedule(function()
            -- We want "safe" labels, but no auto-jump (as the search
            -- command already does that), so just use `safe_labels`
            -- as `labels`, with n/N removed.
            local safe_labels = require("leap").opts.safe_labels
            if type(safe_labels) == "string" then safe_labels = vim.fn.split(safe_labels, "\\zs") end
            local labels = vim.tbl_filter(function(l) return l:match "[^nN]" end, safe_labels)
            -- For `pattern` search, we never need to adjust conceallevel
            -- (no user input).
            local vim_opts = require("leap").opts.vim_opts
            vim_opts["wo.conceallevel"] = nil

            require("leap").leap {
              pattern = vim.fn.getreg "/", -- last search pattern
              target_windows = { vim.fn.win_getid() },
              opts = {
                safe_labels = "",
                labels = labels,
                vim_opts = vim_opts,
              },
            }
          end)
        end
      end,
    })
  end,
}
