-- Built-in terminal integration; no terminal plugin is required.
-- A buffer holds terminal contents and its job, while a window displays a buffer.
-- Only the window is tracked here, not the terminal buffer or its shell process.
local terminal_window = nil

local function toggle_term()
  if terminal_window and vim.api.nvim_win_is_valid(terminal_window) then
    -- Hide the terminal by closing its window, even if its buffer is modified.
    -- The buffer/job may remain alive; reopening below creates a NEW terminal
    -- rather than restoring the hidden one. This is not a persistent toggle.
    vim.api.nvim_win_close(terminal_window, true)
    terminal_window = nil
  else
    -- Open a 15-line horizontal split at the bottom and start Bash explicitly.
    -- term:// starts a terminal job; it does not use a separately installed plugin.
    vim.cmd("botright 15split term://bash")
    terminal_window = vim.api.nvim_get_current_win()
    -- Terminal input mode forwards typing to the shell instead of Neovim.
    vim.cmd("startinsert")
    -- Keep terminal output uncluttered; these options affect only this window.
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end
end

-- In terminal mode ("t"), Esc returns to terminal-normal mode without killing Bash.
-- This makes editor commands available but prevents Esc from reaching terminal apps.
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })
-- In normal mode ("n"), Alt+t toggles the terminal window. Inside the terminal,
-- press Esc first. silent suppresses command echo; desc labels the mapping.
vim.keymap.set('n', '<A-t>', toggle_term, { noremap = true, silent = true, desc = "Toggle terminal" })
