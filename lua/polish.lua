-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

_G.popts = function(...) return require("astrocore").plugin_opts(...) end

_G.inspect = function(...) require("snacks").debug.inspect(...) end
_G.log = function(...) require("snacks").debug.log(...) end
