-- Run without installing plugins: nvim --headless -u NONE -i NONE -l nvim/tests/functional.lua
-- Plugin-facing interfaces are stubbed; Cargo builds and terminal jobs are real.
local config = vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2)))
vim.opt.runtimepath:prepend(vim.fn.fnamemodify(config, ":p"))
local temporary = vim.fn.tempname() .. "-dotfiles-functional"
local jobs = {}
local notifications = {}
local original_notify = vim.notify
vim.notify = function(message, level)
  notifications[#notifications + 1] = { message = message, level = level }
end

local function write(path, content)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(vim.split(content, "\n"), path)
end

local function last_error(fragment)
  local notification = notifications[#notifications]
  assert(notification and notification.level == vim.log.levels.ERROR)
  assert(notification.message:find(fragment, 1, true), notification.message)
end

local function completion()
  -- This suite tests snippets; provider selection and visibility have their own tests.
  package.loaded["copilot-provider"] = { name = "community" }
  local options, jump, expanded
  local events = {}
  local confirm_pair = function() end
  package.loaded["nvim-autopairs.completion.cmp"] = {
    on_confirm_done = function() return confirm_pair end,
  }
  local allowed = false
  local mapping = setmetatable({
    preset = { insert = function(value) return value end },
    scroll_docs = function() return function() end end,
    complete = function() return function() end end,
    abort = function() return function() end end,
    confirm = function(value) return value end,
  }, {
    __call = function(_, callback, modes)
      return { callback = callback, modes = modes }
    end,
  })
  package.loaded.cmp = {
    -- Visibility callbacks are tested separately in usability.lua.
    event = { on = function(_, name, callback) events[name] = callback end },
    mapping = mapping,
    config = {
      window = { bordered = function() return {} end },
      sources = function(primary, fallback) return { primary, fallback } end,
    },
    setup = function(value) options = value end,
  }
  package.loaded.luasnip = {
    locally_jumpable = function() return allowed end,
    jump = function(direction) jump = direction end,
    lsp_expand = function(body) expanded = body end,
  }
  package.loaded["luasnip.loaders.from_vscode"] = { lazy_load = function() end }
  local plugin = dofile(config .. "/lua/plugins/completions.lua")[2]
  assert(vim.list_contains(plugin.dependencies, "hrsh7th/cmp-buffer"))
  assert(vim.list_contains(plugin.dependencies, "windwp/nvim-autopairs"))
  plugin.config()
  assert(events.confirm_done == confirm_pair)
  assert(options.sources[2][1].name == "buffer")
  assert(options.mapping["<CR>"].select == true)
  options.snippet.expand({ body = "${1:example}" })
  assert(expanded == "${1:example}")
  for key, direction in pairs({ ["<C-l>"] = 1, ["<C-h>"] = -1 }) do
    local fallback = false
    options.mapping[key].callback(function() fallback = true end)
    assert(fallback)
    allowed = true
    options.mapping[key].callback(function() error("Unexpected fallback") end)
    assert(jump == direction)
    assert(vim.deep_equal(options.mapping[key].modes, { "i", "s" }))
    allowed = false
  end
  print("PASS: completion dependencies, autopairs integration, source, expansion, snippet navigation and fallback")
end

local function terminal()
  vim.o.shell = vim.fn.exepath("sh") .. " -i"
  dofile(config .. "/lua/terminal-options.lua")
  local toggle = vim.fn.maparg("<A-t>", "n", false, true).callback
  assert(vim.fn.maparg("<A-t>", "t", false, true).callback == toggle)
  toggle()
  local buf = vim.api.nvim_get_current_buf()
  local job = vim.b[buf].terminal_job_id
  jobs[#jobs + 1] = job
  assert(vim.bo[buf].buftype == "terminal")
  assert(vim.bo[buf].bufhidden == "hide")
  assert(not vim.wo.number and not vim.wo.relativenumber and vim.wo.signcolumn == "no")
  assert(vim.fn.jobwait({ job }, 0)[1] == -1)
  vim.fn.chansend(job, "export DOTFILES_TERMINAL_TEST=preserved\n")
  for _ = 1, 3 do
    toggle()
    toggle()
    assert(vim.api.nvim_get_current_buf() == buf)
    assert(vim.b[buf].terminal_job_id == job)
  end
  vim.fn.chansend(job, "printf 'STATE=%s\\n' \"$DOTFILES_TERMINAL_TEST\"\n")
  assert(vim.wait(3000, function()
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n"):find("STATE=preserved", 1, true)
  end))

  -- Closing a window manually must not lose the tracked buffer/job.
  vim.cmd("stopinsert")
  vim.api.nvim_win_close(0, true)
  toggle()
  assert(vim.api.nvim_get_current_buf() == buf and vim.b[buf].terminal_job_id == job)
  local old_window = vim.api.nvim_get_current_win()
  vim.cmd("tabnew")
  toggle()
  assert(vim.api.nvim_get_current_buf() == buf and vim.b[buf].terminal_job_id == job)
  toggle()
  assert(vim.api.nvim_win_is_valid(old_window))
  assert(vim.api.nvim_win_get_buf(old_window) == buf)
  vim.cmd("tabclose")
  vim.api.nvim_set_current_win(old_window)

  -- A floating plugin window does not make the last normal split closable.
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if win ~= old_window then vim.api.nvim_win_close(win, true) end
  end
  local floating = vim.api.nvim_open_win(vim.api.nvim_create_buf(false, true), false, {
    relative = "editor", row = 1, col = 1, width = 10, height = 2,
  })
  toggle()
  assert(vim.api.nvim_win_is_valid(old_window))
  assert(vim.api.nvim_win_get_buf(old_window) ~= buf)
  vim.api.nvim_win_close(floating, true)
  toggle()
  assert(vim.api.nvim_get_current_buf() == buf)
  vim.cmd("stopinsert")
  vim.cmd("bdelete!")
  toggle()
  local replacement = vim.api.nvim_get_current_buf()
  local replacement_job = vim.b[replacement].terminal_job_id
  jobs[#jobs + 1] = replacement_job
  assert(replacement ~= buf and replacement_job ~= job)
  vim.fn.chansend(replacement_job, "exit\n")
  assert(vim.wait(3000, function() return vim.fn.jobwait({ replacement_job }, 0)[1] ~= -1 end))
  assert(not vim.api.nvim_buf_is_valid(replacement))
  toggle()
  local failed = vim.api.nvim_get_current_buf()
  local failed_job = vim.b[failed].terminal_job_id
  jobs[#jobs + 1] = failed_job
  assert(failed ~= replacement)
  vim.fn.chansend(failed_job, "exit 1\n")
  assert(vim.wait(3000, function() return vim.fn.jobwait({ failed_job }, 0)[1] ~= -1 end))
  assert(vim.api.nvim_buf_is_valid(failed))
  toggle()
  toggle()
  assert(vim.api.nvim_get_current_buf() == failed)
  vim.cmd("stopinsert")
  print("PASS: configured shell, persistent state/job, manual close, tabs, floating windows, deletion and exit")
end

local function debugging()
  assert(vim.fn.executable("cargo") == 1, "Cargo is required to run the build regressions")
  local dap = {
    ABORT = {},
    adapters = {},
    configurations = {},
    listeners = { before = { attach = {}, launch = {}, event_terminated = {}, event_exited = {} } },
  }
  for _, name in ipairs({ "toggle_breakpoint", "continue", "step_over", "step_into", "step_out" }) do
    dap[name] = function() end
  end
  package.loaded.dap = dap
  package.loaded.dapui = { setup = function() end, open = function() end, close = function() end }
  dofile(config .. "/lua/plugins/debugging.lua").config()
  assert(#dap.configurations.rust == 5 and #dap.configurations.c == 3 and #dap.configurations.cpp == 3)
  assert(dap.adapters.gdb.args[1] == "--interpreter=dap")
  assert(dap.configurations.rust[1].preRunCommands == nil)

  local executable = vim.fn.executable
  vim.fn.executable = function(name) return name == "gdb" and 0 or executable(name) end
  assert(dap.configurations.c[1]().program == dap.ABORT)
  last_error("GDB is not on PATH")
  vim.fn.executable = function(name) return name == "gdb" and 1 or executable(name) end

  local workspace = temporary .. "/workspace with spaces"
  write(workspace .. "/Cargo.toml", '[workspace]\nmembers = ["first", "second"]\nresolver = "2"\n')
  write(workspace .. "/first/Cargo.toml", [=[
[package]
name = "package-not-binary-name"
version = "0.1.0"
edition = "2021"
[[bin]]
name = "alpha"
path = "src/one.rs"
[[bin]]
name = "beta"
path = "src/two.rs"
[[test]]
name = "integration"
path = "tests/custom.rs"
]=])
  write(workspace .. "/first/src/one.rs", 'fn main() { println!("alpha"); }\n')
  write(workspace .. "/first/src/two.rs", 'fn main() { println!("beta"); }\n')
  write(workspace .. "/first/tests/custom.rs", "#[test]\nfn example() { assert_eq!(2 + 2, 4); }\n")
  write(workspace .. "/second/Cargo.toml", '[package]\nname = "gamma"\nversion = "0.1.0"\nedition = "2021"\n')
  write(workspace .. "/second/src/main.rs", 'fn main() { println!("gamma"); }\n')
  local target = temporary .. "/custom target directory"
  local old_target, old_offline = vim.env.CARGO_TARGET_DIR, vim.env.CARGO_NET_OFFLINE
  vim.env.CARGO_TARGET_DIR, vim.env.CARGO_NET_OFFLINE = target, "true"
  local cargo = require("debugging.cargo")
  local selections, cancel, count = {}, false, 0
  local original_select = vim.ui.select
  vim.ui.select = function(items, options, callback)
    count = count + 1
    selections = items
    assert(options.format_item(items[1]):find(items[1].path, 1, true))
    callback(not cancel and items[#items] or nil)
  end
  local function build(root, tests)
    local done, result = false, nil
    local waiting = coroutine.create(function()
      local parent = coroutine.running()
      local option = cargo.program(root, tests)
      vim.schedule(function()
        local resumed, err = coroutine.resume(option, parent)
        assert(resumed, err)
      end)
      result = coroutine.yield()
      done = true
    end)
    assert(coroutine.resume(waiting))
    assert(not done, "Cargo must not block while resolving the program")
    assert(vim.wait(60000, function() return done end, 10), "Cargo resolution timed out")
    return result
  end

  local binary = build(workspace, false)
  assert(#selections == 3)
  assert(binary:sub(1, #target) == target and vim.fn.executable(binary) == 1)
  local run = vim.system({ binary }, { text = true }):wait()
  assert(run.code == 0 and run.stdout:find("gamma", 1, true))
  local test_binary = build(workspace, true)
  assert(#selections >= 4 and vim.fn.executable(test_binary) == 1)
  local tests = vim.system({ test_binary, "--list" }, { text = true }):wait()
  assert(tests.code == 0)
  local before = count
  assert(build(workspace .. "/second", false) ~= dap.ABORT and count == before)
  cancel = true
  assert(build(workspace, false) == dap.ABORT)
  cancel = false
  write(workspace .. "/first/src/one.rs", "fn main() { missing_function(); }\n")
  assert(build(workspace, false) == dap.ABORT)
  last_error("missing_function")
  print("PASS: asynchronous Cargo JSON builds, workspaces, multiple/single targets, custom paths, tests and errors")

  vim.cmd.edit(workspace .. "/second/src/main.rs")
  local resolved = dap.configurations.rust[1]()
  assert(resolved.cwd == workspace .. "/second")
  assert(type(resolved.program()) == "thread")
  local input = vim.fn.input
  vim.fn.input = function() return "DOTFILES_OVERRIDE=debug" end
  local env = resolved.env()
  assert(env.DOTFILES_OVERRIDE == "debug" and env.PATH == vim.env.PATH)
  local test_env = dap.configurations.rust[2]().env()
  assert(test_env.RUST_BACKTRACE == "1" and test_env.PATH == vim.env.PATH)
  vim.fn.input = function() return "malformed" end
  assert(resolved.env() == dap.ABORT)
  last_error("Invalid environment override")
  vim.fn.input = function() return "" end
  assert(dap.configurations.c[1]().program() == dap.ABORT)
  assert(#resolved.args() == 0)
  vim.fn.input = input
  vim.cmd("enew!")
  vim.cmd.cd(temporary)
  assert(dap.configurations.rust[1]().program == dap.ABORT)
  last_error("No Cargo.toml")

  local system = vim.system
  vim.system = function(_, _, callback)
    callback({ code = 0, signal = 0, stdout = "{not valid JSON}\n", stderr = "" })
    return {}
  end
  assert(build(workspace, false) == dap.ABORT)
  last_error("Invalid JSON")
  vim.system = function(_, _, callback)
    callback({ code = 0, signal = 0, stdout = '{"reason":"build-finished","success":true}\n', stderr = "" })
    return {}
  end
  assert(build(workspace, false) == dap.ABORT)
  last_error("no runnable")
  vim.system = function(_, _, callback)
    callback({
      code = 0, signal = 15, stderr = "terminated",
      stdout = vim.json.encode({
        reason = "compiler-artifact", executable = binary,
        profile = { test = false }, target = { name = "stale", kind = { "bin" } },
      }) .. "\n",
    })
    return {}
  end
  assert(build(workspace, false) == dap.ABORT)
  last_error("terminated")
  vim.system = function() error("simulated spawn failure") end
  assert(build(workspace, false) == dap.ABORT)
  last_error("Could not start Cargo")
  vim.system = system
  vim.fn.executable = function(name) return name == "cargo" and 0 or executable(name) end
  assert(build(workspace, false) == dap.ABORT)
  last_error("Cargo is not on PATH")
  vim.fn.executable = executable
  vim.ui.select = original_select
  vim.env.CARGO_TARGET_DIR, vim.env.CARGO_NET_OFFLINE = old_target, old_offline
  print("PASS: debug profiles, cancellation, environment inheritance, invalid input and missing prerequisites")
end

local ok, err = xpcall(function()
  vim.fn.mkdir(temporary, "p")
  completion()
  if arg[1] == "--completion" then return end
  terminal()
  debugging()
end, debug.traceback)
for _, job in ipairs(jobs) do
  if vim.fn.jobwait({ job }, 0)[1] == -1 then vim.fn.jobstop(job) end
end
vim.notify = original_notify
vim.fn.delete(temporary, "rf")
assert(ok, err)
print(arg[1] == "--completion" and "PASS: focused completion regressions" or "PASS: all functional regressions")
