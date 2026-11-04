-- Editor-wide defaults, loaded before plugin configuration.
-- vim.cmd executes Vim commands; vim.opt provides a Lua interface to options.

-- Insert spaces instead of literal tab characters.
vim.cmd("set expandtab")
-- Display an existing tab as two columns. softtabstop controls the number of
-- columns used by Tab/Backspace while editing; shiftwidth controls indentation.
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- <leader> expands to Space in mappings: <leader>ff means Space, f, f.
-- This is a prefix, not a key that must be held down.
vim.g.mapleader = " "
-- <localleader> is a separate prefix, conventionally used for filetype mappings.
vim.g.maplocalleader = "\\"

-- Together these show the absolute number on the cursor line and relative
-- distances elsewhere, making motions such as 5j (five lines down) easier.
vim.opt.number = true
vim.opt.relativenumber = true
