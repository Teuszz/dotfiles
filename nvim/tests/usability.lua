-- Run without plugins: nvim --headless -u NONE -i NONE -l nvim/tests/usability.lua
local config = vim.fn.fnamemodify(vim.fs.dirname(vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))), ":p")
vim.opt.runtimepath:prepend(config)
vim.g.mapleader = " "
local temporary = vim.fn.tempname() .. "-dotfiles-usability"
vim.fn.mkdir(temporary .. "/directory with spaces", "p")
local original_notify, original_select = vim.notify, vim.ui.select
local original_stdpath = vim.fn.stdpath
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
  local preview = dofile(config .. "/lua/plugins/markdown-preview.lua")
  assert(vim.deep_equal(preview.ft, { "markdown" }))
  assert(vim.deep_equal(preview.cmd, { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" }))
  assert(preview.build == "cd app && npm install --omit=dev --no-audit --no-fund")
  local preview_globals = {}
  for _, name in ipairs({ "mkdp_filetypes", "mkdp_auto_start", "mkdp_open_to_the_world", "mkdp_echo_preview_url" }) do
    preview_globals[name] = { value = vim.g[name] }
  end
  preview.init()
  assert(vim.deep_equal(vim.g.mkdp_filetypes, { "markdown" }))
  assert(vim.g.mkdp_auto_start == 0 and vim.g.mkdp_open_to_the_world == 0 and vim.g.mkdp_echo_preview_url == 1)
  for name, saved in pairs(preview_globals) do vim.g[name] = saved.value end
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
  local statusline = dofile(config .. "/lua/plugins/lualine.lua")
  assert(statusline.dependencies[2][1] == "catppuccin/nvim")
  assert(statusline.dependencies[2].name == "catppuccin")
  local previous_lualine, statusline_options = package.loaded.lualine, nil
  package.loaded.lualine = { setup = function(options) statusline_options = options end }
  statusline.config()
  assert(statusline_options.options.theme == "catppuccin-nvim")
  package.loaded.lualine = previous_lualine
  local lock = vim.json.decode(table.concat(vim.fn.readfile(config .. "/lazy-lock.json"), "\n"))
  assert(lock["cmp-buffer"] and lock["telescope-ui-select.nvim"] and lock["lazy.nvim"])
  assert(lock["markdown-preview.nvim"] and lock["markdown-preview.nvim"].branch == "master")
  for _, revision in pairs(lock) do assert(#revision.commit == 40 and revision.commit:match("^%x+$")) end
  print("PASS: lazy triggers, startup Treesitter, Catppuccin status-line theme and lockfile entries")
end

local function buffer_closing()
  local previous = package.loaded.bufferline
  local options, elements = nil, {}
  package.loaded.bufferline = {
    setup = function(value) options = value.options end,
    get_elements = function() return { elements = elements } end,
  }
  dofile(config .. "/lua/plugins/bufferline.lua").config()
  local close = vim.fn.maparg("<leader>bd", "n", false, true).callback
  assert(type(close) == "function" and options.close_command == options.right_mouse_command)
  local initial_window = vim.api.nvim_get_current_win()
  local initial_buffer = vim.api.nvim_get_current_buf()
  local first = vim.api.nvim_create_buf(true, false)
  local second = vim.api.nvim_create_buf(true, false)
  local third = vim.api.nvim_create_buf(true, false)
  local sidebar = vim.api.nvim_create_buf(false, true)
  vim.bo[sidebar].filetype = "neo-tree"
  vim.cmd("leftabove 20vsplit")
  local tree_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(tree_window, sidebar)
  vim.api.nvim_set_current_win(initial_window)
  vim.api.nvim_win_set_buf(initial_window, second)
  vim.cmd("split")
  local other_window = vim.api.nvim_get_current_win()
  vim.cmd("tabnew")
  local tab_window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(tab_window, second)
  vim.api.nvim_set_current_win(other_window)
  elements = { { id = first }, { id = second }, { id = third } }
  local width = vim.api.nvim_win_get_width(tree_window)
  local count = #vim.api.nvim_list_wins()
  close()
  assert(not vim.api.nvim_buf_is_valid(second))
  for _, win in ipairs({ initial_window, other_window, tab_window }) do
    assert(vim.api.nvim_win_is_valid(win) and vim.api.nvim_win_get_buf(win) == third)
  end
  assert(#vim.api.nvim_list_wins() == count and vim.api.nvim_win_get_width(tree_window) == width)
  assert(vim.api.nvim_win_get_buf(tree_window) == sidebar)
  vim.api.nvim_win_close(tab_window, true)
  count = #vim.api.nvim_list_wins()

  elements = { { id = first }, { id = third } }
  vim.api.nvim_buf_set_lines(third, 0, -1, false, { "unsaved" })
  close()
  assert(vim.api.nvim_buf_is_valid(third) and vim.api.nvim_get_current_buf() == third)
  assert(notifications[#notifications][1]:find("unsaved", 1, true))
  vim.bo[third].modified = false
  options.close_command(third)
  assert(vim.api.nvim_get_current_buf() == first, "Use the previous buffer at the end of the list")

  -- Close a hidden buffer without changing the active window or creating a buffer.
  local hidden = vim.api.nvim_create_buf(true, false)
  options.right_mouse_command(hidden)
  assert(not vim.api.nvim_buf_is_valid(hidden) and vim.api.nvim_get_current_buf() == first)
  vim.api.nvim_set_current_win(tree_window)
  close()
  assert(vim.api.nvim_buf_is_valid(sidebar) and notifications[#notifications][1]:find("file buffer", 1, true))
  vim.api.nvim_set_current_win(other_window)

  -- Exclude buffers belonging to earlier tests when exercising the last-file case.
  local listed = {}
  for _, id in ipairs(vim.api.nvim_list_bufs()) do
    if id ~= first and vim.bo[id].buflisted then
      listed[#listed + 1] = id
      vim.bo[id].buflisted = false
    end
  end
  elements = { { id = first } }
  close()
  local empty = vim.api.nvim_get_current_buf()
  assert(empty ~= first and vim.bo[empty].buflisted and vim.bo[empty].buftype == "")
  assert(vim.api.nvim_buf_get_name(empty) == "" and not vim.bo[empty].modified)
  assert(vim.api.nvim_win_get_buf(initial_window) == empty and #vim.api.nvim_list_wins() == count)
  assert(vim.api.nvim_win_get_width(tree_window) == width)

  -- A newly opened file can be missing from the tabline's cached elements.
  local fresh = vim.api.nvim_create_buf(true, false)
  close()
  assert(vim.api.nvim_get_current_buf() == fresh and not vim.api.nvim_buf_is_valid(empty))
  vim.api.nvim_win_close(other_window, true)
  vim.api.nvim_win_close(tree_window, true)
  vim.api.nvim_set_current_win(initial_window)
  vim.api.nvim_win_set_buf(initial_window, initial_buffer)
  for _, id in ipairs(listed) do
    if vim.api.nvim_buf_is_valid(id) then vim.bo[id].buflisted = true end
  end
  vim.api.nvim_buf_delete(fresh, { force = true })
  vim.api.nvim_buf_delete(sidebar, { force = true })
  package.loaded.bufferline = previous
  print("PASS: layout-preserving buffer close, neighbors, unsaved protection, sidebar and last-file fallback")
end

local function copilot()
  -- Use a temporary installation-local file, never the user's real selection.
  local previous_provider = package.loaded["copilot-provider"]
  vim.fn.stdpath = function(kind)
    return kind == "config" and temporary or original_stdpath(kind)
  end
  local selection_path = temporary .. "/copilot-local.lua"
  local function select_provider(source)
    if source then
      vim.fn.writefile({ source }, selection_path)
    else
      vim.fn.delete(selection_path)
    end
    package.loaded["copilot-provider"] = nil
    return require("copilot-provider")
  end
  local count = #notifications
  assert(select_provider(nil).name == nil)
  vim.wait(20)
  assert(#notifications == count + 1 and notifications[#notifications][2] == vim.log.levels.WARN)
  assert(notifications[#notifications][1]:find(selection_path, 1, true))
  for _, spec in ipairs(dofile(config .. "/lua/plugins/copilot.lua")) do
    assert(spec.enabled == false, "Missing selection must not enable any Copilot plugin")
  end
  for _, source in ipairs({
    "return 'unknown'", "return 'lua'", "return 'vim'",
    "return nil", "return {}", "return true", "not valid Lua",
  }) do
    local ok, err = pcall(select_provider, source)
    assert(not ok and tostring(err):find(selection_path, 1, true))
  end
  assert(select_provider('return "community"').name == "community")
  -- A running session keeps its choice; editing the local file requires a restart.
  vim.fn.writefile({ 'return "official"' }, selection_path)
  assert(require("copilot-provider").name == "community")

  -- Test both alternatives without authentication or network access.
  local specs = dofile(config .. "/lua/plugins/copilot.lua")
  local inline, chat, official = specs[1], specs[2], specs[3]
  assert(inline.enabled and chat.enabled and official.enabled == false)
  assert(inline[1] == "zbirenbaum/copilot.lua" and inline.main == "copilot")
  assert(inline.event == "InsertEnter" and inline.cmd == "Copilot")
  assert(inline.opts.server.type == "binary" and inline.opts.auth_provider_url == nil)
  assert(inline.opts.panel.enabled == false and inline.opts.suggestion.auto_trigger == true)
  assert(inline.opts.suggestion.hide_during_completion == true)
  local maps = inline.opts.suggestion.keymap
  assert(maps.accept == "<M-l>" and maps.next == "<M-]>" and maps.prev == "<M-[>")
  assert(maps.dismiss == "<C-]>" and maps.accept_word == false and maps.accept_line == false)
  assert(inline.opts.filetypes["copilot-chat"] == false)
  assert(chat[1] == "CopilotC-Nvim/CopilotChat.nvim" and chat.main == "CopilotChat")
  assert(chat.dependencies[1] == "nvim-lua/plenary.nvim")
  assert(vim.tbl_contains(chat.cmd, "CopilotChat") and vim.tbl_contains(chat.cmd, "CopilotChatModels"))
  assert(chat.keys[1][1] == "<leader>ac" and vim.tbl_contains(chat.keys[1].mode, "x"))
  for _, mapping in ipairs(chat.keys) do assert(mapping.desc) end
  assert(chat.opts.selection == "visual" and vim.deep_equal(chat.opts.resources, { "selection" }))
  assert(vim.tbl_isempty(chat.opts.tools) and vim.tbl_isempty(chat.opts.instruction_files))
  assert(chat.opts.allow_insecure == false and chat.opts.window.layout == "vertical")
  -- The local login selects the account; shared options must not pin a company
  -- proxy or model that would prevent personal access on another computer.
  assert(chat.opts.proxy == nil and chat.opts.model == nil)
  assert(inline.opts.copilot_model == nil and inline.opts.server_opts_overrides == nil)
  assert(official[1] == "github/copilot.vim" and official.branch == "release")
  assert(official.event == "InsertEnter" and official.cmd == "Copilot")
  assert(select_provider('return "official"').name == "official")
  local selected = dofile(config .. "/lua/plugins/copilot.lua")
  assert(selected[1].enabled == false and selected[2].enabled == false and selected[3].enabled)
  select_provider('return "community"')
  local lock = vim.json.decode(table.concat(vim.fn.readfile(config .. "/lazy-lock.json"), "\n"))
  assert(lock["copilot.lua"] and lock["CopilotChat.nvim"] and lock["copilot.vim"])

  -- Stub cmp's interface to test existing mappings/sources and both real event
  -- callbacks without installing plugins.
  local previous_cmp, previous_snippets = package.loaded.cmp, package.loaded.luasnip
  local previous_loader = package.loaded["luasnip.loaders.from_vscode"]
  local events, options, snippet_loaded = {}, nil, false
  local mapping = setmetatable({
    preset = { insert = function(value) return value end },
    scroll_docs = function() return function() end end,
    complete = function() return function() end end,
    abort = function() return function() end end,
    confirm = function(value) return value end,
  }, { __call = function(_, callback) return callback end })
  package.loaded.cmp = {
    event = { on = function(_, name, callback) events[name] = callback end },
    mapping = mapping,
    config = {
      window = { bordered = function() return {} end },
      sources = function(primary, fallback) return { primary, fallback } end,
    },
    setup = function(value) options = value end,
  }
  package.loaded.luasnip = { locally_jumpable = function() return false end }
  package.loaded["luasnip.loaders.from_vscode"] = {
    lazy_load = function() snippet_loaded = true end,
  }
  dofile(config .. "/lua/plugins/completions.lua")[2].config()
  assert(snippet_loaded and options.mapping["<CR>"].select == true)
  assert(options.sources[1][1].name == "nvim_lsp" and options.sources[1][2].name == "luasnip")
  assert(options.sources[2][1].name == "buffer")
  for _, lhs in ipairs({ "<C-l>", "<C-h>" }) do
    local fallback_called = false
    options.mapping[lhs](function() fallback_called = true end)
    assert(fallback_called)
  end
  local first = vim.api.nvim_create_buf(true, false)
  local second = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(first)
  events.menu_opened()
  assert(vim.b[first].copilot_suggestion_hidden == true)
  assert(vim.b[second].copilot_suggestion_hidden == nil)
  events.menu_closed()
  assert(vim.b[first].copilot_suggestion_hidden == false)

  -- The official provider must not replace Tab or snippet mappings.
  local global_names = {
    "copilot_no_tab_map", "copilot_no_maps", "copilot_filetypes",
    "copilot_hide_during_completion", "loaded_copilot",
  }
  local globals = {}
  for _, name in ipairs(global_names) do globals[name] = vim.g[name] end
  local tab_before = vim.fn.maparg("<Tab>", "i", false, true)
  official.init()
  official.config()
  assert(vim.g.copilot_no_tab_map and vim.g.copilot_no_maps and vim.g.copilot_hide_during_completion)
  assert(vim.g.copilot_filetypes.yaml == false and vim.g.copilot_filetypes.markdown == false)
  assert(vim.deep_equal(tab_before, vim.fn.maparg("<Tab>", "i", false, true)))
  local accept = vim.fn.maparg("<M-l>", "i", false, true)
  assert(accept.expr == 1 and accept.rhs == 'copilot#Accept("\\<M-l>")')
  local methods = { ["<M-]>"] = "Next", ["<M-[>"] = "Previous", ["<C-]>"] = "Dismiss" }
  for lhs, method in pairs(methods) do
    local name = "copilot#" .. method
    local original = vim.fn[name]
    local called = false
    vim.fn[name] = function() called = true end
    local key = vim.fn.maparg(lhs, "i", false, true)
    assert(key.desc)
    key.callback()
    assert(called)
    vim.fn[name] = original
    vim.keymap.del("i", lhs)
  end
  vim.keymap.del("i", "<M-l>")

  select_provider('return "official"')
  dofile(config .. "/lua/plugins/completions.lua")[2].config()
  local clear = vim.fn["copilot#Clear"]
  local cleared = 0
  vim.fn["copilot#Clear"] = function() cleared = cleared + 1 end
  vim.g.loaded_copilot = 1
  for _, value in ipairs({ false, true }) do
    vim.b[first].copilot_disabled = value
    events.menu_opened()
    events.menu_opened()
    assert(vim.b[first].copilot_disabled == true)
    assert(vim.b[second].copilot_disabled == nil)
    events.menu_closed()
    assert(vim.b[first].copilot_disabled == value, "Keep the user's buffer override")
    assert(vim.b[first].copilot_cmp_saved_disabled == nil)
  end
  assert(cleared == 4)
  vim.b[first].copilot_disabled = nil
  vim.g.loaded_copilot = nil
  events.menu_opened()
  assert(cleared == 4, "Opening cmp must not load an inactive Copilot plugin")
  events.menu_closed()
  assert(vim.b[first].copilot_disabled == nil)
  events.menu_closed()
  assert(vim.b[first].copilot_disabled == nil)
  vim.fn["copilot#Clear"] = clear
  for _, name in ipairs(global_names) do vim.g[name] = globals[name] end

  select_provider(nil)
  vim.wait(20)
  dofile(config .. "/lua/plugins/completions.lua")[2].config()
  vim.b[first].copilot_suggestion_hidden = nil
  events.menu_opened()
  events.menu_closed()
  assert(vim.b[first].copilot_disabled == nil and vim.b[first].copilot_suggestion_hidden == nil)
  vim.api.nvim_buf_delete(first, { force = true })
  vim.api.nvim_buf_delete(second, { force = true })
  package.loaded.cmp, package.loaded.luasnip = previous_cmp, previous_snippets
  package.loaded["luasnip.loaders.from_vscode"] = previous_loader
  package.loaded["copilot-provider"] = previous_provider
  vim.fn.stdpath = original_stdpath
  print("PASS: mandatory Copilot choice, provider exclusivity, mappings, lockfile and cmp visibility")
end

local ok, err = xpcall(function()
  if arg[1] == "--buffer-closing" then
    buffer_closing()
    return
  end
  if arg[1] == "--loading" then
    loading()
    return
  end
  startup()
  lsp()
  loading()
  buffer_closing()
  copilot()
end, debug.traceback)
vim.notify, vim.ui.select = original_notify, original_select
vim.fn.stdpath = original_stdpath
vim.fn.delete(temporary, "rf")
assert(ok, err)
print(arg[1] and "PASS: focused usability regressions" or "PASS: all usability regressions")
