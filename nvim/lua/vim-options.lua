-- SOME GENERAL CONFIGURATIONS --

-- Tabs to spaces
vim.cmd("set expandtab")
-- How many spaces for a tab
vim.cmd("set tabstop=2")
vim.cmd("set softtabstop=2")
vim.cmd("set shiftwidth=2")

-- sets the global leader key to the space character. 
-- The leader key is used as a prefix for many custom keyboard shortcuts in Neovim.
vim.g.mapleader = " "
-- sets the local leader key to the backslash character. 
-- The local leader key is similar to the main leader but is typically used for filetype specific commands.
vim.g.maplocalleader = "\\"

vim.opt.number = true
vim.opt.relativenumber = true
