-- Run: nvim -l tests/jdtls_probes_test.lua   (prints PASS/FAIL, exits non-zero on failure)
--
-- Loads the REAL helper chunk out of jdtls_config.lua (everything above the
-- `return function()` module body) so there is no copied-logic drift, then drives
-- find_jdk8/find_jdk21 against stubbed filesystems — and the whole module body
-- against a stubbed require("jdtls"). Stubs, not this machine: the fleet spans
-- arm64/x86_64 macOS and Linux, so a test that asserted real paths would only be
-- true on one box. The real machine is exercised once, for invariants only.
local path = vim.fn.expand "$HOME/.config/nvim/lua/plugins/config/jdtls_config.lua"
local src = table.concat(vim.fn.readfile(path), "\n")
local head = assert(src:match "^(.-)\nreturn function%(%)", "could not split helpers from module body")
local chunk = head .. "\nreturn find_jdk8, find_jdk21, is_jdk8"

local function probes(env) return assert(load(chunk, "@jdtls_probes", "t", env or _G))() end

local ORACLE8 = "/Library/Java/JavaVirtualMachines/jdk-1.8.jdk/Contents/Home"
local ZULU8 = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home"
local APPLET = "/Library/Internet Plug-Ins/JavaAppletPlugin.plugin/Contents/Home"
local BREW21 = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
local JVM_GLOB = "/Library/Java/JavaVirtualMachines/*/Contents/Home"

local fails = 0
local function check(label, got, want)
  local ok = got == want
  if not ok then fails = fails + 1 end
  print(string.format("%-48s %s", label, ok and "PASS" or "FAIL"))
  if not ok then print("  got : " .. tostring(got) .. "\n  want: " .. tostring(want)) end
end

-- What each JDK home actually ships. The applet plugin is the interesting one:
-- a release file claiming 1.8 and no compiler, which is why both tests exist.
local SHIPS = {
  [ORACLE8] = { javac = true, version = "1.8.0_441" },
  [ZULU8] = { javac = true, version = "1.8.0_452" },
  [APPLET] = { javac = false, version = "1.8.0_441" },
  [BREW21] = { javac = true, version = "21.0.1" },
}

-- A stubbed macOS box. `installed` is what exists on disk, `java_home` is what
-- /usr/libexec/java_home nominates (it answers even when that is a lie), and
-- `jvm_dir` is what the /Library/Java glob expands to.
local function mac_env(o)
  local seen, homes = {}, {}
  for _, h in ipairs(o.installed or {}) do
    homes[h] = SHIPS[h]
  end
  local fn = setmetatable({
    has = function(what) return what == "mac" and 1 or 0 end,
    system = function(cmd)
      seen.cmd = cmd
      return (o.java_home or "") .. "\n"
    end,
    glob = function(pat) return pat == JVM_GLOB and (o.jvm_dir or {}) or {} end,
    executable = function(p)
      local h = homes[(p:gsub("/bin/javac$", ""))]
      return h and h.javac and 1 or 0
    end,
    filereadable = function(p) return homes[(p:gsub("/release$", ""))] and 1 or 0 end,
    readfile = function(p) return { 'JAVA_VERSION="' .. homes[(p:gsub("/release$", ""))].version .. '"' } end,
  }, { __index = vim.fn })
  local env = setmetatable({
    vim = setmetatable({ fn = fn, env = { JAVA_HOME = o.java_home_env } }, { __index = vim }),
  }, { __index = _G })
  local find_jdk8 = probes(env)
  return find_jdk8, seen
end

-- ~/.java_env's JAVA_HOME is honoured, but only after it is verified.
check("mac: JAVA_HOME=jdk8 honoured", mac_env { installed = { ORACLE8 }, java_home_env = ORACLE8 }(), ORACLE8)
check(
  "mac: JAVA_HOME=applet JRE rejected",
  mac_env { installed = { APPLET, ORACLE8 }, java_home_env = APPLET, java_home = APPLET, jvm_dir = { ORACLE8 } }(),
  ORACLE8
)
check(
  "mac: JAVA_HOME=jdk21 rejected (wrong version)",
  mac_env { installed = { BREW21, ORACLE8 }, java_home_env = BREW21, java_home = ORACLE8 }(),
  ORACLE8
)

-- No JAVA_HOME (GUI-launched nvim): java_home nominates, is_jdk8 confirms.
local mac8, seen = mac_env { installed = { ORACLE8 }, java_home = ORACLE8 }
check("mac: java_home nominates a real jdk8", mac8(), ORACLE8)
check("mac: asks java_home for -v 1.8.0", table.concat(seen.cmd, " "), "/usr/libexec/java_home -v 1.8.0")

-- The regression this test exists for: java_home ranks the javac-less applet
-- JRE above the real JDK 8 and JAVA_HOME is unset, so only the /Library/Java
-- scan finds the install.
check(
  "mac: applet outranks -> JVM dir scan wins",
  mac_env { installed = { APPLET, ZULU8 }, java_home = APPLET, jvm_dir = { APPLET, ZULU8 } }(),
  ZULU8
)
-- java_home never fails: given no Java 8 it prints the NEWEST JDK and exits 0.
check(
  "mac: java_home 'never fails' lie rejected",
  mac_env { installed = { BREW21 }, java_home = BREW21, jvm_dir = { BREW21 } }(),
  nil
)
check("mac: nothing installed", mac_env { installed = {}, java_home = "" }(), nil)

-- Linux branch: stub has/executable/glob and assert the ordering (linuxbrew keg
-- before /usr/lib/jvm) and that the glob list is consumed as a list.
local LINUXBREW8 = "/home/linuxbrew/.linuxbrew/opt/openjdk@8/libexec"
local DISTRO8 = "/usr/lib/jvm/java-8-openjdk-amd64"
local function linux_env(present)
  local fn = setmetatable({
    has = function(what) return what == "mac" and 0 or 1 end,
    executable = function(p) return present[(p:gsub("/bin/javac$", ""))] and 1 or 0 end,
    filereadable = function() return 0 end,
    glob = function() return { DISTRO8 } end,
  }, { __index = vim.fn })
  return probes(setmetatable({
    vim = setmetatable({ fn = fn, env = {} }, { __index = vim }),
  }, { __index = _G }))
end
check("linux: linuxbrew keg wins", linux_env { [LINUXBREW8] = true, [DISTRO8] = true }(), LINUXBREW8)
check("linux: distro fallback via glob", linux_env { [DISTRO8] = true }(), DISTRO8)
check("linux: nothing installed", linux_env {}(), nil)

-- find_jdk21: prefix order and layout order, both stubbed.
local function jdk21_env(dirs, prefix)
  local fn = setmetatable({
    isdirectory = function(p) return dirs[p] and 1 or 0 end,
  }, { __index = vim.fn })
  local _, find_jdk21 = probes(setmetatable({
    vim = setmetatable({ fn = fn, env = { HOMEBREW_PREFIX = prefix } }, { __index = vim }),
  }, { __index = _G }))
  return find_jdk21
end
local CUSTOM_MAC = "/custom/brew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home"
local CUSTOM_LINUX = "/custom/brew/opt/openjdk@21/libexec"
check("jdk21: no HOMEBREW_PREFIX (nil-truncation guard)", jdk21_env { [BREW21] = true }(), BREW21)
check(
  "jdk21: HOMEBREW_PREFIX wins, Linux layout",
  jdk21_env({ [CUSTOM_LINUX] = true, [BREW21] = true }, "/custom/brew")(),
  CUSTOM_LINUX
)
check(
  "jdk21: macOS layout preferred within a prefix",
  jdk21_env({ [CUSTOM_LINUX] = true, [CUSTOM_MAC] = true }, "/custom/brew")(),
  CUSTOM_MAC
)
check("jdk21: nothing installed", jdk21_env {}(), nil)

-- The real machine, invariants only (the exact paths differ per box): whatever
-- comes back must be a usable JDK, and find_jdk8 must never return a JRE.
local real8, real21, is_jdk8 = probes()
local got8, got21 = real8(), real21()
print(
  ("\nthis machine: JAVA_HOME=%s\n  jdk8  = %s\n  jdk21 = %s\n"):format(
    tostring(vim.env.JAVA_HOME),
    tostring(got8),
    tostring(got21)
  )
)
check("real: find_jdk8 returns nil or a JDK 8", got8 == nil or is_jdk8(got8), true)
check("real: find_jdk21 returns nil or a dir", got21 == nil or vim.fn.isdirectory(got21) == 1, true)

-- Whole module body: stubbed probes + stubbed require("jdtls"), so the runtimes
-- table, the WARN branch and the memoization are asserted without launching a
-- language server. (Headless nvim cannot observe the real notify: snacks.nvim
-- swaps vim.notify for a float notifier.) `state` is read on every stub call, so
-- flipping it mid-test is how the cache gets caught re-probing.
local function module_under_test(state)
  local notes, captured = {}, nil
  local fn = setmetatable({
    has = function(what) return what == "mac" and 1 or 0 end,
    system = function() return "" end,
    -- The module also globs Mason's java-test jars, which wants a string back.
    glob = function(pat, _, list)
      if pat == JVM_GLOB then return state.have8 and { ORACLE8 } or {} end
      return list and {} or ""
    end,
    executable = function(p) return state.have8 and p == ORACLE8 .. "/bin/javac" and 1 or 0 end,
    filereadable = function(p) return state.have8 and p == ORACLE8 .. "/release" and 1 or 0 end,
    readfile = function() return { 'JAVA_VERSION="1.8.0_441"' } end,
    isdirectory = function(p) return state.have21 and p == BREW21 and 1 or 0 end,
  }, { __index = vim.fn })
  local env = setmetatable({
    vim = setmetatable({
      fn = fn,
      env = {},
      notify = function(msg, lvl) table.insert(notes, { msg = msg, lvl = lvl }) end,
    }, { __index = vim }),
    require = function(m)
      if m == "jdtls" then return { start_or_attach = function(cfg) captured = cfg end } end
      return require(m)
    end,
  }, { __index = _G })
  local setup = assert(load(src, "@jdtls_config", "t", env))()
  return function()
    setup()
    return captured.settings.java.configuration.runtimes, notes
  end
end

local run = module_under_test { have8 = true, have21 = true }
local rt, notes = run()
check(
  "module: both runtimes",
  #rt .. "|" .. rt[1].name .. "|" .. tostring(rt[1].default) .. "|" .. rt[2].name,
  "2|JavaSE-1.8|true|JavaSE-21"
)
check("module: no warn when jdk8 found", #notes, 0)

local state = { have8 = false, have21 = true }
run = module_under_test(state)
rt, notes = run()
check("module: jdk21 only when no jdk8", #rt .. "|" .. rt[1].name, "1|JavaSE-21")
check("module: WARN fired", notes[1] and notes[1].lvl, vim.log.levels.WARN)
check("module: WARN mentions no JDK 8", notes[1].msg:find("no JDK 8", 1, true) ~= nil, true)

-- Memoized: give the stubbed box a JDK 8, then re-run as a second `FileType
-- java` buffer would. Same answer and still one WARN = the probes did not rerun.
state.have8 = true
rt, notes = run()
check("module: probes memoized across buffers", #rt .. "|" .. rt[1].name, "1|JavaSE-21")
check("module: WARN fires at most once", #notes, 1)

check("module: empty runtimes when nothing found", #module_under_test { have8 = false, have21 = false }(), 0)

print(fails == 0 and "\nALL PROBE CHECKS PASS" or ("\n" .. fails .. " PROBE CHECKS FAILED"))
os.exit(fails == 0 and 0 or 1)
