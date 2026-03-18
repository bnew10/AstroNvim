-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      diagnostics = true,
    },
    filetypes = {
      extension = {
        gitconfig = "gitconfig",
      },
    },
    options = {
      opt = {
        iskeyword = vim.list_extend(vim.opt.iskeyword:get(), { "-" }),
        completeopt = { "menu", "menuone", "noselect", "fuzzy" },
        scrolloff = 4,
      },
    },
    autocmds = {
      bufhistory = {
        {
          -- event = "BufEnter",
          event = "BufWinEnter",
          callback = function(args)
            if args.file ~= "" then
              -- vim.notify("is file enter: " .. vim.fs.basename(args.file), "info")
              local viahist = vim.g.viahist or false

              if not viahist then
                -- vim.notify("not viahist: " .. vim.fs.basename(args.file), "info")
                local bufhist = vim.g.bufhist or {}
                local prevbuf = vim.g.prevbuf

                bufhist[args.buf] = { prevbuf = prevbuf, nextbuf = nil }
                if bufhist[prevbuf] ~= nil then bufhist[prevbuf].nextbuf = args.buf end

                vim.g.bufhist = bufhist
                vim.g.prevbuf = args.buf
              end
              vim.g.viahist = false
            end
          end,
        },
      },
    },
    mappings = {
      n = {
        -- dap
        ["<Leader>df"] = { function() require("dap").focus_frame() end, desc = "Focus current execution point" },
        ["<Leader>dl"] = {
          function()
            require("dap").list_breakpoints(false)
            require("snacks").picker.qflist { title = "Breakpoints" }
          end,
          desc = "List breakpoints quickfix",
        },
        ["<Leader>dv"] = {
          function()
            local widgets = require "dap.ui.widgets"
            widgets.centered_float(widgets.scopes)
          end,
          desc = "Inspect variables in popup",
        },

        -- buffer reordering
        ["gb"] = {
          function()
            local bufs = vim.t.bufs
            local idx = 1
            for i, bufnr in ipairs(bufs) do
              if bufnr == vim.api.nvim_get_current_buf() then idx = i end
            end
            local distance = vim.v.count - idx
            require("astrocore.buffer").move(distance)
          end,
          desc = "Move buffer to index [count]",
        },
        -- buffer switching
        ["[B"] = {
          function()
            local bufnr = vim.t.bufs[1]
            vim.cmd.buffer(bufnr)
          end,
          desc = "First buffer",
        },
        ["]B"] = {
          function()
            local bufnr = vim.t.bufs[#vim.t.bufs]
            vim.cmd.buffer(bufnr)
          end,
          desc = "Last buffer",
        },
        -- ["<C-p>"] = {
        --   function()
        --     local bufnr = vim.api.nvim_get_current_buf()
        --     local bufhist = vim.g.bufhist or {}
        --     local cur_bufhist = bufhist[bufnr] or {}
        --
        --     if cur_bufhist.prevbuf ~= nil then
        --       vim.g.viahist = true
        --       vim.cmd(("%s %d"):format("buffer", cur_bufhist.prevbuf))
        --     end
        --   end,
        --   desc = "Go backward in buffer history",
        -- },
        -- ["<C-n>"] = {
        --   function()
        --     local bufnr = vim.api.nvim_get_current_buf()
        --     local bufhist = vim.g.bufhist or {}
        --     local cur_bufhist = bufhist[bufnr] or {}
        --
        --     if cur_bufhist.nextbuf ~= nil then
        --       vim.g.viahist = true
        --       vim.cmd(("%s %d"):format("buffer", cur_bufhist.nextbuf))
        --     end
        --   end,
        --   desc = "Go forward in buffer history",
        -- },

        -- Yank
        ["<Leader>Y"] = { desc = "Yank..." },
        ["<Leader>Yn"] = {
          function()
            local lineNr = assert(vim.fn.line ".", "Failed to get line number")
            vim.fn.setreg("+", lineNr)
          end,
          desc = "line number",
        },

        -- miscellaneous
        ["<Leader>xc"] = { "<cmd>cclose<cr>", desc = "Close quickfix window" },
        ["<Leader>W"] = { "<cmd>wall<cr>", desc = "Save all" },
        ["<Leader>z"] = { "<cmd>tab split<cr>", desc = "Open in new tab" },
        ["g]"] = { "<C-]>", desc = "Go to tag" },
        ["<Leader>bh"] = {
          function() require("astrocore.buffer").close_left() end,
          desc = "Close all buffers to the left",
        },
        ["<Leader>bl"] = {
          function() require("astrocore.buffer").close_right() end,
          desc = "Close all buffers to the right",
        },
        ["<Leader>br"] = false,
        ["<Leader>c"] = { function() require("astrocore.buffer").close() end, desc = "Close buffer" },
        ["<Leader>o"] = { "<cmd>only<cr>", desc = "Close all other windows" },
        ["<Leader>O"] = { "<cmd>tabonly<cr>", desc = "Close all other tabs" },
        ["<Leader>e"] = { "<Cmd>confirm qall<CR>", desc = "Exit AstroNvim" },
        ["<Leader>Q"] = { "<cmd>tabc<cr>", desc = "Quit Tab" },
        ["[T"] = { "<cmd>tabfirst<cr>", desc = "First tab" },
        ["]T"] = { "<cmd>tablast<cr>", desc = "Last tab" },
      },
      v = {
        ["gs"] = { function() require("strike").toggle_visual_strike() end, desc = "strikethrough visual selection" },
      },
      c = {
        ["<C-a>"] = { "<Home>", desc = "Move cursor to beginning of line" },
        ["<C-e>"] = { "<End>", desc = "Move cursor to end of line" },
        ["<C-b>"] = { "<Left>", desc = "Move cursor one char back" },
        ["<C-f>"] = { "<Right>", desc = "Move cursor one char forward" },
        ["<M-b>"] = { "<S-Left>", desc = "Move cursor one word back" },
        ["<M-f>"] = { "<S-Right>", desc = "Move cursor one word forward" },
        ["<C-d>"] = { "<Del>", desc = "Delete one char forward" },
      },
    },
  },
}
