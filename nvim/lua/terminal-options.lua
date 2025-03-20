local terminal_window = nil

local function toggle_term()
  if terminal_window and vim.api.nvim_win_is_valid(terminal_window) then
    -- Close the terminal window if it's open
    vim.api.nvim_win_close(terminal_window, true)
    terminal_window = nil
  else
    -- Open a new terminal window
    vim.cmd("botright 15split term://bash")
    terminal_window = vim.api.nvim_get_current_win()
    vim.cmd("startinsert")
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
  end
end

-- Exit terminal mode
vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]], { noremap = true, silent = true, desc = "Exit terminal mode" })
-- Map the toggle function to a key
vim.keymap.set('n', '<A-t>', toggle_term, { noremap = true, silent = true, desc = "Toggle terminal" })
