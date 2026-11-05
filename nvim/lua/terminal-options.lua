-- Built-in terminal integration; no terminal plugin is required.
-- A buffer holds terminal contents and its job, while a window displays a buffer.
-- Keep the buffer/job alive when hiding the window, so shell state is preserved.
local terminal_buffer = nil

local function toggle_term()
  -- Look up the actual window instead of retaining a potentially stale window ID.
  -- Only hide windows in this tab; other tabs can display the same terminal buffer.
  local windows = vim.api.nvim_tabpage_list_wins(0)
  local normal_windows = 0
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_get_config(win).relative == "" then
      normal_windows = normal_windows + 1
    end
  end
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_get_buf(win) == terminal_buffer then
      vim.cmd("stopinsert")
      if normal_windows == 1 and vim.api.nvim_win_get_config(win).relative == "" then
        -- Floating windows do not count: keep the last editor split and replace its contents.
        vim.api.nvim_win_set_buf(win, vim.api.nvim_create_buf(true, false))
      else
        vim.api.nvim_win_close(win, true)
      end
      return
    end
  end

  -- Splitting an existing window avoids creating an unused buffer on each reopen.
  vim.cmd("botright 15split")
  if terminal_buffer and vim.api.nvim_buf_is_valid(terminal_buffer) then
    vim.api.nvim_win_set_buf(0, terminal_buffer)
  else
    vim.api.nvim_win_set_buf(0, vim.api.nvim_create_buf(true, false))
    -- :terminal uses Neovim's configured 'shell', including any shell arguments.
    vim.cmd("terminal")
    terminal_buffer = vim.api.nvim_get_current_buf()
    vim.bo[terminal_buffer].bufhidden = "hide"
  end

  -- Reuse retained output too. Neovim normally deletes shells that exit successfully;
  -- the next toggle then creates a fresh buffer/job through the branch above.
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false
  vim.opt_local.signcolumn = "no"
  vim.cmd("startinsert")
end

-- In terminal mode ("t"), Esc returns to terminal-normal mode without killing Bash.
-- This makes editor commands available but prevents Esc from reaching terminal apps.
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })
-- Alt+t works both from the editor and directly inside the terminal.
vim.keymap.set({ 'n', 't' }, '<A-t>', toggle_term, { noremap = true, silent = true, desc = "Toggle terminal" })
