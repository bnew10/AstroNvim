if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

local ui = require "astroui"
local component = require "astroui.status.component"
local status_utils = require "astroui.status.utils"
local hl = require "astroui.status.hl"
local condition = require "astroui.status.condition"

local pending = false

local function lsp_request()
  local opts = {
    lsp_request_pending = {
      condition = function() return pending end,
      provider = function()
        local spinner = ui.get_spinner("LSPLoading", 1) or { "" }
        return status_utils.stylize(spinner[0])
      end,
      str = "",
      padding = { right = 1 },
      update = {
        "LspRequest",
        callback = function(args)
          local request = args.data.request
          if request.method == "textDocument/references" then
            pending = request.type == "pending"
            vim.schedule(vim.cmd.redrawstatus)
          end
        end,
      },
    },
    hl = hl.get_attributes "lsp",
    surround = { separator = "right", color = "lsp_bg", condition = condition.lsp_attached },
  }

  return component.builder(status_utils.setup_providers(opts, { "lsp_request_pending" }))
end

---@type LazySpec
return {
  "rebelot/heirline.nvim",
  opts = function(_, opts) table.insert(opts, 10, lsp_request()) end,
}
