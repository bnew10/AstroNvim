---@type LazySpec
return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "AstroNvim/astroui", opts = { icons = { Harpoon = "󱡀" } } },
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local harpoon = require "harpoon"
        local maps = assert(opts.mappings)
        local prefix = "<Leader>h"

        maps.n[prefix] = { desc = require("astroui").get_icon("Harpoon", 1, true) .. "Harpoon" }

        maps.n[prefix .. "a"] = { function() harpoon:list():add() end, desc = "Add file" }

        maps.n[prefix .. "e"] =
          { function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Toggle quick menu" }

        maps.n[prefix .. "1"] = { function() harpoon:list():select(1) end, desc = "Select mark 1" }
        maps.n[prefix .. "2"] = { function() harpoon:list():select(2) end, desc = "Select mark 2" }
        maps.n[prefix .. "3"] = { function() harpoon:list():select(3) end, desc = "Select mark 3" }
        maps.n[prefix .. "4"] = { function() harpoon:list():select(4) end, desc = "Select mark 4" }
        maps.n[prefix .. "5"] = { function() harpoon:list():select(5) end, desc = "Select mark 5" }
        maps.n[prefix .. "6"] = { function() harpoon:list():select(6) end, desc = "Select mark 6" }
        maps.n[prefix .. "7"] = { function() harpoon:list():select(7) end, desc = "Select mark 7" }
        maps.n[prefix .. "8"] = { function() harpoon:list():select(8) end, desc = "Select mark 8" }
        maps.n[prefix .. "9"] = { function() harpoon:list():select(9) end, desc = "Select mark 9" }
      end,
    },
  },
  config = function()
    local harpoon = require "harpoon"
    local extensions = require "harpoon.extensions"

    harpoon:setup()
    harpoon:extend(extensions.builtins.highlight_current_file())
    harpoon:extend(extensions.builtins.navigate_with_number())
  end,
}
