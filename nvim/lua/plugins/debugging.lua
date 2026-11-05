-- nvim-dap controls an external debugger; dap-ui displays variables, stack and
-- breakpoints, and nvim-nio supports dap-ui's asynchronous work.
return {
  "mfussenegger/nvim-dap",
  -- Lazy key stubs preserve the shortcuts before the debugger is loaded.
  keys = {
    { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "DAP toggle breakpoint" },
    { "<F5>", function() require("dap").continue() end, desc = "DAP start or continue" },
    { "<F10>", function() require("dap").step_over() end, desc = "DAP step over" },
    { "<F11>", function() require("dap").step_into() end, desc = "DAP step into" },
    { "<F12>", function() require("dap").step_out() end, desc = "DAP step out" },
  },
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio"
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local cargo = require("debugging.cargo")
    dapui.setup()

    -- Open panels when attaching/launching and close them when the session ends.
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

    -- Requires GDB 14+ built with Python/DAP support. Use GDB's documented launch
    -- options below; preRunCommands/runInTerminal are not GDB DAP launch options.
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
    }

    local function executable()
      local path = vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      if path == "" then
        return dap.ABORT
      end
      path = vim.fn.fnamemodify(path, ":p")
      if vim.fn.filereadable(path) == 0 then
        vim.notify("Executable does not exist or is unreadable: " .. path, vim.log.levels.ERROR)
        return dap.ABORT
      end
      return path
    end

    local function arguments()
      -- Preserve the existing space-separated prompt; shell quoting is not interpreted.
      return vim.split(vim.fn.input('Arguments (space-separated): '), " ", { trimempty = true })
    end

    local function environment()
      -- GDB replaces the entire environment when env is supplied. Start with the
      -- inherited environment so PATH and other variables survive custom overrides.
      local env = vim.fn.environ()
      local input = vim.fn.input('Environment overrides (KEY=value, separated by spaces): ')
      for pair in input:gmatch("%S+") do
        local key, value = pair:match("^([%a_][%w_]*)=(.*)$")
        if not key then
          vim.notify("Invalid environment override: " .. pair .. " (expected KEY=value)", vim.log.levels.ERROR)
          return dap.ABORT
        end
        env[key] = value
      end
      return env
    end

    -- Callable configurations capture the project root once per launch, before
    -- asynchronous builds or UI pickers can change the active buffer/directory.
    local function profile(config, tests)
      return setmetatable(config, {
        __call = function()
          local function abort(message)
            vim.notify(message, vim.log.levels.ERROR)
            return { name = config.name, type = config.type, request = config.request, program = dap.ABORT }
          end

          if vim.fn.executable("gdb") == 0 then
            return abort("GDB is not on PATH. Install GDB 14+ with Python/DAP support.")
          end

          local resolved = vim.deepcopy(config)
          setmetatable(resolved, nil)
          if tests ~= nil then
            local root = vim.fs.root(0, "Cargo.toml") or vim.fs.root(vim.fn.getcwd(), "Cargo.toml")
            if not root then
              return abort("No Cargo.toml found for the current file or working directory.")
            end
            resolved.cwd = root
            resolved.program = function()
              return cargo.program(root, tests)
            end
          end
          return resolved
        end,
      })
    end

    -- Manual profiles work for Rust, C and C++; compile with debug information first.
    local manual = {
      profile({
        name = "Launch Custom Binary",
        type = "gdb",
        request = "launch",
        program = executable,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
      }),
      profile({
        name = "Select and attach to process",
        type = "gdb",
        request = "attach",
        program = executable,
        pid = function()
          local name = vim.fn.input('Executable name (filter): ')
          return require("dap.utils").pick_process({ filter = name })
        end,
        cwd = "${workspaceFolder}"
      }),
      profile({
        name = "Attach to gdbserver :1234",
        type = "gdb",
        request = "attach",
        target = "localhost:1234",
        program = executable,
        cwd = "${workspaceFolder}"
      }),
    }
    dap.configurations.c = vim.deepcopy(manual)
    dap.configurations.cpp = vim.deepcopy(manual)
    dap.configurations.rust = {
      profile({
        name = "Debug Cargo Project",
        type = "gdb",
        request = "launch",
        stopAtBeginningOfMainSubprogram = false,
        args = arguments,
        env = environment,
      }, false),
      profile({
        name = "Debug Cargo Test",
        type = "gdb",
        request = "launch",
        stopAtBeginningOfMainSubprogram = false,
        args = function()
          -- Pass an optional test-name filter directly to Rust's test harness.
          local filter = vim.fn.input('Test filter (empty for all tests): ')
          return filter ~= "" and { filter } or {}
        end,
        env = function()
          return vim.tbl_extend("force", vim.fn.environ(), { RUST_BACKTRACE = "1" })
        end,
      }, true),
    }
    vim.list_extend(dap.configurations.rust, manual)

  end
}
