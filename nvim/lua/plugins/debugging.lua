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

    -- Configure C/C++/Rust via gdb, see https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation#ccrust-via-gdb 
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
    }

    dap.configurations.rust = {
      {
        name = "Debug Cargo Project",
        type = "gdb",
        request = "launch",
        program = function()
          -- Auto-detect the binary from Cargo.toml
          local cargo_toml = vim.fn.findfile("Cargo.toml", vim.fn.getcwd() .. ";")
          if cargo_toml ~= "" then
            local cmd = "grep -m 1 '^name' " .. cargo_toml .. " | cut -d '\"' -f2"
            local bin_name = vim.fn.system(cmd):gsub("%s+$", "")
            local target_dir = vim.fn.getcwd() .. "/target/debug/" .. bin_name
            if vim.fn.filereadable(target_dir) == 1 then
              return target_dir
            end
          end
          -- Fallback to manual input
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
        runInTerminal = false,
        args = function()
          return vim.split(vim.fn.input('Arguments: '), " ")
        end,
        env = function()
          local env_str = vim.fn.input('Environment variables (KEY=value KEY2=value2): ')
          if env_str == "" then return {} end

          local env = {}
          for pair in env_str:gmatch("%S+") do
            local key, value = pair:match("([^=]+)=(.*)")
            if key and value then env[key] = value end
          end
          return env
        end,
        preRunCommands = {"rust-info"}
      },
      {
        name = "Debug Cargo Test",
        type = "gdb",
        request = "launch",
        program = function()
          -- Run cargo test with --no-run to compile and identify the test executable
          local test_cmd = "cargo test --no-run 2>&1"
          local test_output = vim.fn.system(test_cmd)

          -- Extract the path to the test binary
          local test_bin = test_output:match("Running `([^`]+)")
          if test_bin then return test_bin end

          -- Fallback to manual input
          return vim.fn.input('Path to test executable: ', vim.fn.getcwd() .. '/target/debug/deps/', 'file')
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
        runInTerminal = false,
        args = function()
          -- Allow filtering tests
          local filter = vim.fn.input('Test filter (empty for all tests): ')
          if filter ~= "" then
            return {filter}
          end
          return {}
        end,
        env = {
          RUST_BACKTRACE = "1"
        },
        preRunCommands = {"rust-info"}
      },
      -- Keep your existing configurations
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
        type = 'gdb',
        request = 'attach',
        target = 'localhost:1234',
        program = function()
          return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
        end,
        cwd = '${workspaceFolder}'
      },
    }

    vim.keymap.set('n', '<Leader>b', dap.toggle_breakpoint, {})
    vim.keymap.set('n', '<F5>', dap.continue, {})
    vim.keymap.set('n', '<F10>', dap.step_over, {})
    vim.keymap.set('n', '<F11>', dap.step_into, {})
    vim.keymap.set('n', '<F12>', dap.step_out, {})
  end
}
