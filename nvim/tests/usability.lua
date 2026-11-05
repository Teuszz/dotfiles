-- Run without plugins: nvim --headless -u NONE -i NONE -l nvim/tests/usability.lua
local config = vim.fn.fnamemodify(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))), ":p")
vim.opt.runtimepath:prepend(config)
vim.g.mapleader = " "
local temporary = vim.fn.tempname() .. "-dotfiles-usability"
vim.fn.mkdir(temporary .. "/directory with spaces", "p")
local original_notify, original_select = vim.notify, vim.ui.select
local notifications = {}
vim.notify = function(message, level) notifications[#notifications + 1] = { message, level } end

local function startup()
  local original_argc, original_argv = vim.fn.argc, vim.fn.argv
  local args, opened = {}, nil
  vim.fn.argc = function() return #args end
  vim.fn.argv = function(index) return args[index + 1] end
  package.loaded["neo-tree.command"] = { execute = function(options) opened = options end }
  local cwd = vim.fn.getcwd()
  local function enter(values)
    args, opened = values, nil
    require("startup").setup()
    vim.api.nvim_exec_autocmds("VimEnter", {})
  end
  enter({})
  assert(opened == nil)
  enter({ temporary .. "/file.lua" })
  assert(opened == nil)
  enter({ temporary .. "/directory with spaces" })
  assert(opened.dir == temporary .. "/directory with spaces/")
  assert(opened.position == "left" and vim.fn.getcwd() == cwd)
  enter({ temporary .. "/directory with spaces", temporary .. "/file.lua" })
  assert(opened == nil)
  vim.fn.argc, vim.fn.argv = original_argc, original_argv
  print("PASS: empty/file/directory/multiple startup policy and paths with spaces")
end

local function lsp()
  local get_clients, attached, format = vim.lsp.get_clients, vim.lsp.buf_is_attached, vim.lsp.buf.format
  local clients, formatted, selection = {}, nil, nil
  local connected = true
  vim.lsp.get_clients = function() return clients end
  vim.lsp.buf_is_attached = function() return connected end
  vim.lsp.buf.format = function(options) formatted = options end
  vim.ui.select = function(items, _, callback) selection = { items, callback } end
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buf)
  require("lsp-options").setup()
  require("lsp-options").setup()
  assert(#vim.api.nvim_get_autocmds({ group = "ConfiguredLsp", event = "LspAttach" }) == 1)
  local function key(lhs, mode) return vim.fn.maparg(lhs, mode or "n", false, true) end
  assert(vim.tbl_isempty(key("gd")))
  vim.api.nvim_exec_autocmds("LspAttach", { buffer = buf, data = { client_id = 1 } })
  for _, lhs in ipairs({ "K", "gd", "gD", "gi", "<leader>ca", "<leader>cf" }) do
    assert(key(lhs).buffer == 1 and key(lhs).desc)
  end
  assert(key("<leader>ca", "x").buffer == 1)
  local format_buffer = key("<leader>cf").callback
  format_buffer()
  assert(notifications[#notifications][2] == vim.log.levels.WARN and formatted == nil)
  clients = { { id = 1, name = "first" } }
  format_buffer()
  assert(formatted.bufnr == buf and formatted.id == 1 and formatted.async == false and formatted.timeout_ms == 3000)
  formatted = nil
  clients = { { id = 2, name = "second" }, { id = 1, name = "first" } }
  format_buffer()
  assert(selection[1][1].id == 1 and formatted == nil)
  selection[2](nil)
  assert(formatted == nil)
  selection[2](selection[1][2])
  assert(formatted.id == 2)
  connected, formatted = false, nil
  selection[2](selection[1][1])
  assert(formatted == nil and notifications[#notifications][1]:find("detached", 1, true))
  vim.api.nvim_exec_autocmds("LspDetach", { buffer = buf, data = { client_id = 1 } })
  vim.wait(20)
  assert(key("gd").buffer == 1, "Keep maps while another server is attached")
  clients = {}
  -- Native cleanup or another plugin may already have removed/replaced a mapping.
  vim.keymap.del("n", "K", { buffer = buf })
  vim.keymap.set("n", "gi", function() end, { buffer = buf, desc = "User replacement" })
  vim.api.nvim_exec_autocmds("LspDetach", { buffer = buf, data = { client_id = 2 } })
  vim.api.nvim_exec_autocmds("LspDetach", { buffer = buf, data = { client_id = 2 } })
  assert(vim.wait(1000, function() return vim.tbl_isempty(key("gd")) end))
  assert(vim.tbl_isempty(key("<leader>cf")) and vim.tbl_isempty(key("<leader>ca", "x")))
  assert(key("gi").desc == "User replacement")
  vim.lsp.get_clients, vim.lsp.buf_is_attached, vim.lsp.buf.format = get_clients, attached, format
  print("PASS: buffer-local LSP maps, formatter selection/cancellation/errors and last-client detach")
end

local function loading()
  local completion = dofile(config .. "/lua/plugins/completions.lua")
  assert(completion[2].event == "InsertEnter")
  local debugging = dofile(config .. "/lua/plugins/debugging.lua")
  assert(#debugging.keys == 5)
  for _, key in ipairs(debugging.keys) do assert(key.desc and type(key[2]) == "function") end
  local telescope = dofile(config .. "/lua/plugins/telescope.lua")[1]
  assert(telescope.cmd == "Telescope" and #telescope.keys == 2)
  local old_telescope = package.loaded.telescope
  package.loaded.telescope = {}
  telescope.init()
  local select_ok, select_error = pcall(vim.ui.select, {}, {}, function() end)
  assert(not select_ok and select_error:find("failed to initialize", 1, true))
  package.loaded.telescope = old_telescope
  vim.ui.select = original_select
  local explorer = dofile(config .. "/lua/plugins/neo-tree.lua")
  assert(explorer.cmd == "Neotree" and explorer.opts and explorer.keys[1].desc)
  assert(explorer.opts.filesystem.hijack_netrw_behavior == "disabled")
  assert(explorer.opts.filesystem.bind_to_cwd == false)
  local treesitter = dofile(config .. "/lua/plugins/treesitter.lua")
  assert(treesitter.lazy == false)
  local lock = vim.json.decode(table.concat(vim.fn.readfile(config .. "/lazy-lock.json"), "\n"))
  assert(lock["cmp-buffer"] and lock["telescope-ui-select.nvim"] and lock["lazy.nvim"])
  for _, revision in pairs(lock) do assert(#revision.commit == 40 and revision.commit:match("^%x+$")) end
  print("PASS: lazy triggers, startup Treesitter and complete commit-shaped lockfile entries")
end

local ok, err = xpcall(function()
  startup()
  lsp()
  loading()
end, debug.traceback)
vim.notify, vim.ui.select = original_notify, original_select
vim.fn.delete(temporary, "rf")
assert(ok, err)
print("PASS: all usability regressions")
