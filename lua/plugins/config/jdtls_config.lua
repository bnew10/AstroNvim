-- A "JDK home" is only usable as a jdtls runtime if it ships a compiler. The check
-- is not paranoia: /usr/libexec/java_home ranks the browser applet-plugin JRE above
-- a real JDK 8 even on a Mac that has one installed (it version-ranks 1.8.441.07
-- above 1.8.0_441), and that JRE's release file claims 1.8 too — bin/javac is the
-- only thing that actually tells the two apart.
local function is_jdk(home) return home ~= nil and home ~= "" and vim.fn.executable(home .. "/bin/javac") == 1 end

local function is_jdk8(home)
  if not is_jdk(home) then return false end
  local release = home .. "/release"
  if vim.fn.filereadable(release) == 0 then return false end
  for _, line in ipairs(vim.fn.readfile(release)) do
    if line:find('JAVA_VERSION="1.8', 1, true) then return true end
  end
  return false
end

-- Runtimes are probed rather than hardcoded because the fleet spans arm64 and
-- x86_64 macOS plus Debian-family Linux, and no single path survives all three:
-- brew's openjdk@8 pins `depends_on arch: :x86_64` on macOS, so on Apple Silicon
-- it *errors* rather than merely lacking a bottle (Java 8 comes from the zulu@8
-- cask under /Library/Java/JavaVirtualMachines instead).
local function find_jdk8()
  -- ~/.java_env exports JAVA_HOME, so honour it first — but verify the version.
  -- It is plain user env and may point at any JDK; a wrong-version *default*
  -- runtime never errors, it just type-checks Java 8 code against newer semantics.
  if is_jdk8(vim.env.JAVA_HOME) then return vim.env.JAVA_HOME end

  if vim.fn.has "mac" == 1 then
    -- java_home nominates a candidate; it does not answer the question, because
    -- it lies twice. (1) It never fails: an unmatched -v prints the NEWEST JDK
    -- and exits 0, so checking shell_error is dead weight and `-v 1.8` would
    -- happily hand back JDK 21 on a box with no Java 8 — hence the version test
    -- in is_jdk8, and `-v 1.8.0`, the prefix every real JDK 8 uses. (2) It ranks
    -- the applet-plugin JRE (1.8.441.07) above the real JDK (1.8.0_441) — hence
    -- the javac test. So verify with is_jdk8, then scan the standard JVM dir
    -- ourselves: that is what finds an Oracle/Zulu install when the applet
    -- plugin outranks it and JAVA_HOME is unset (GUI-launched Neovim). Mirrors
    -- machine-config's dot_java_env.
    local home = vim.trim(vim.fn.system { "/usr/libexec/java_home", "-v", "1.8.0" })
    if is_jdk8(home) then return home end
    for _, h in ipairs(vim.fn.glob("/Library/Java/JavaVirtualMachines/*/Contents/Home", true, true)) do
      if is_jdk8(h) then return h end
    end
  else
    -- Linux: brew's openjdk@8 is keg-only and its JAVA_HOME is the keg's libexec;
    -- then whatever the distro packaged.
    local candidates = { "/home/linuxbrew/.linuxbrew/opt/openjdk@8/libexec" }
    vim.list_extend(candidates, vim.fn.glob("/usr/lib/jvm/java-8-openjdk-*", true, true))
    for _, home in ipairs(candidates) do
      if is_jdk(home) then return home end
    end
  end
end

local function find_jdk21()
  local prefixes = { "/opt/homebrew", "/usr/local", "/home/linuxbrew/.linuxbrew" }
  -- Prepended, not written into the literal: a nil first element would truncate
  -- the table and ipairs would walk nothing (HOMEBREW_PREFIX is only exported by
  -- interactive shells, so it is absent for GUI/agent-spawned Neovim).
  if vim.env.HOMEBREW_PREFIX then table.insert(prefixes, 1, vim.env.HOMEBREW_PREFIX) end
  for _, prefix in ipairs(prefixes) do
    -- openjdk@21 is keg-only, so its JAVA_HOME lives under the keg's libexec —
    -- and macOS nests a .jdk bundle in there where Linux does not.
    for _, home in ipairs {
      prefix .. "/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home",
      prefix .. "/opt/openjdk@21/libexec",
    } do
      if vim.fn.isdirectory(home) == 1 then return home end
    end
  end
end

-- The module body runs once per `FileType java` buffer, so an unmemoized probe
-- forks java_home and re-stats the filesystem for every Java file opened — and
-- re-fires the WARN below each time. No JDK appears mid-session, so resolve on
-- the first buffer and reuse; the warning then lands at most once per session.
local resolved
local function resolve_jdks()
  if not resolved then
    resolved = { jdk8 = find_jdk8(), jdk21 = find_jdk21() }
    if not resolved.jdk8 then
      -- Loud, because the failure is otherwise invisible: with no JavaSE-1.8
      -- entry jdt.ls silently falls back to the JDK it runs on (21+) for Java 8
      -- projects.
      vim.notify(
        "jdtls: no JDK 8 found — Java 8 projects will resolve against the server's JDK."
          .. " macOS: brew install --cask zulu@8",
        vim.log.levels.WARN
      )
    end
  end
  return resolved
end

return function()
  local buf_name = vim.api.nvim_buf_get_name(0)
  local root_dir = vim.fs.root(0, { ".git", "mvnw", "pom.xml" }) or vim.fs.dirname(buf_name)

  -- Build bundles list for debug adapter and test runner
  local bundles = {
    vim.fn.expand "$MASON/share/java-debug-adapter/com.microsoft.java.debug.plugin.jar",
  }
  vim.list_extend(bundles, vim.split(vim.fn.glob("$MASON/share/java-test/*.jar", true), "\n", { trimempty = true }))

  local runtimes = {}
  local jdks = resolve_jdks()
  if jdks.jdk8 then table.insert(runtimes, { name = "JavaSE-1.8", path = jdks.jdk8, default = true }) end
  if jdks.jdk21 then table.insert(runtimes, { name = "JavaSE-21", path = jdks.jdk21 }) end

  local config = {
    name = "jdtls",

    -- Startup args (JDK, workspace, config dir) handled by ~/.local/bin/jdtls wrapper
    -- Must use absolute path because Mason prepends its bin/ to PATH inside Neovim
    cmd = { vim.fn.expand "$HOME/.local/bin/jdtls" },

    root_dir = root_dir,

    -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
    settings = {
      java = {
        eclipse = { downloadSources = true },
        configuration = {
          updateBuildConfiguration = "interactive",
          runtimes = runtimes,
        },
        maven = { downloadSources = true },
        implementationsCodeLens = { enabled = true },
        referencesCodeLens = { enabled = true },
        inlayHints = { parameterNames = { enabled = "all" } },
        signatureHelp = { enabled = true },
        completion = {
          favoriteStaticMembers = {
            "org.hamcrest.MatcherAssert.assertThat",
            "org.hamcrest.Matchers.*",
            "org.hamcrest.CoreMatchers.*",
            "org.junit.jupiter.api.Assertions.*",
            "java.util.Objects.requireNonNull",
            "java.util.Objects.requireNonNullElse",
            "org.mockito.Mockito.*",
          },
        },
        sources = {
          organizeImports = {
            starThreshold = 9999,
            staticStarThreshold = 9999,
          },
        },
      },
    },

    init_options = {
      bundles = bundles,
    },

    on_attach = function(...)
      local astrolsp_avail, astrolsp = pcall(require, "astrolsp")
      if astrolsp_avail then astrolsp.on_attach(...) end
    end,
  }
  require("jdtls").start_or_attach(config, { dap = { hotcodereplace = "auto" } })
end
