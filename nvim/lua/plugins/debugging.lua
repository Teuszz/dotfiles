-- nvim-dap is a Debug Adapter Protocol client, not a debugger itself.
-- It controls an external debugger (GDB here); dap-ui adds variables, stack,
-- breakpoint and console panels, and nvim-nio supports dap-ui's asynchronous work.
return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio"
  },
  config = function ()
    local dap = require("dap")
    local dapui = require("dapui")

    require("dapui").setup()

    -- Open panels when attaching/launching and close them when the session ends.
    -- dapui_config is a listener key so these callbacks can be identified/replaced.
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    -- Start GDB as a DAP adapter and enable pretty printing for structured values.
    -- Requires a GDB build with DAP support available as "gdb" on PATH.
    -- An adapter defines how to talk to a debugger; configurations below define
    -- what to debug. Although GDB supports C/C++ too, only Rust is configured here.
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
    }

    -- These profiles appear when starting debugging from a Rust buffer.
    -- Functions used as option values prompt/detect values when a session starts.
    dap.configurations.rust = {
      {
        name = "Debug Cargo Project",
        type = "gdb",
        request = "launch",
        program = function()
          -- Search upward for Cargo.toml, then guess target/debug/<package-name>.
          -- This does not build the project. It assumes a simple single-binary
          -- layout and does not reliably handle workspaces or custom target paths.
          local cargo_toml = vim.fn.findfile("Cargo.toml", vim.fn.getcwd() .. ";")
          if cargo_toml ~= "" then
            -- This text-based name lookup is not a TOML parser; an unquoted
            -- manifest path also fails when the path contains spaces.
            local cmd = "grep -m 1 '^name' " .. cargo_toml .. " | cut -d '\"' -f2"
            local bin_name = vim.fn.system(cmd):gsub("%s+$", "")
            local target_dir = vim.fn.getcwd() .. "/target/debug/" .. bin_name
            if vim.fn.filereadable(target_dir) == 1 then
              return target_dir
            end
          end
          -- If the guessed executable is missing, ask for a path with file completion.
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        -- nvim-dap expands this placeholder to Neovim's current working directory.
        cwd = "${workspaceFolder}",
        -- Do not pause automatically at main; use breakpoints to stop execution.
        stopAtBeginningOfMainSubprogram = false,
        -- Request no separate terminal for the debugged program.
        runInTerminal = false,
        args = function()
          -- Split on spaces only; shell-style quoting and escaping are not parsed.
          return vim.split(vim.fn.input('Arguments: '), " ")
        end,
        env = function()
          local env_str = vim.fn.input('Environment variables (KEY=value KEY2=value2): ')
          if env_str == "" then return {} end

          -- Parse whitespace-separated KEY=value pairs. Values containing spaces
          -- are not supported, and malformed entries are silently skipped.
          local env = {}
          for pair in env_str:gmatch("%S+") do
            local key, value = pair:match("([^=]+)=(.*)")
            if key and value then env[key] = value end
          end
          return env
        end,
        -- Legacy adapter-specific option; do not assume GDB executes this command.
        preRunCommands = {"rust-info"}
      },
      {
        name = "Debug Cargo Test",
        type = "gdb",
        request = "launch",
        program = function()
          -- Compile tests without executing them; capture stdout and stderr together.
          -- This synchronous call blocks Neovim until Cargo finishes and does not
          -- check Cargo's exit status before trying to detect a test executable.
          local test_cmd = "cargo test --no-run 2>&1"
          local test_output = vim.fn.system(test_cmd)

          -- Known limitation: --no-run normally reports "Executable", not "Running".
          -- This pattern therefore generally falls through to manual selection.
          -- Cargo's --message-format=json would provide structured artifact paths.
          local test_bin = test_output:match("Running `([^`]+)")
          if test_bin then return test_bin end

          -- Ask for a compiled test binary when automatic detection fails.
          return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/target/debug/deps/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
        runInTerminal = false,
        args = function()
          -- Pass an optional test-name filter to Rust's test harness.
          local filter = vim.fn.input('Test filter (empty for all tests): ')
          if filter ~= "" then
            return {filter}
          end
          return {}
        end,
        env = {
          -- Ask Rust to print a backtrace when a test panics.
          RUST_BACKTRACE = "1"
        },
        preRunCommands = {"rust-info"}
      },
      -- Manual launch: select an already-built executable instead of using Cargo.
      {
        name = "Launch Custom Binary",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
      },
      {
        name = "Select and attach to process",
        -- Attach to a running process instead of launching a new one. The local
        -- executable supplies symbols; the process picker supplies its PID.
        type = "gdb",
        request = "attach",
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        pid = function()
          local name = vim.fn.input('Executable name (filter): ')
          return require("dap.utils").pick_process({ filter = name })
        end,
        cwd = '${workspaceFolder}'
      },
      {
        name = 'Attach to gdbserver :1234',
        -- Intended remote-attach profile: requires an already-running gdbserver
        -- and adapter support for this profile's target option.
        type = 'gdb',
        request = 'attach',
        target = 'localhost:1234',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}'
      },
    }

    -- Space+b toggles a breakpoint. F5 starts/continues a session; F10 steps over
    -- calls, F11 steps into them, and F12 runs until the current function returns.
    vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, {})
    vim.keymap.set('n', '<F5>', dap.continue, {})
    vim.keymap.set('n', '<F10>', dap.step_over, {})
    vim.keymap.set('n', '<F11>', dap.step_into, {})
    vim.keymap.set('n', '<F12>', dap.step_out, {})
  end
}
