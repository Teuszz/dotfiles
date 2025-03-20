-- INSTALL PACKAGE MANAGER --

-- Installs and runs packages for neovim. There are two major package managers for neovim, packer.nvim and lazy.nvim
--
-- Installing lazy.nvim (see Single File Setup at http://www.lazyvim.org/installation):
--
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ 
	  "git",
  	  "clone",
	  "--filter=blob:none",
	  "--branch=stable",
	  lazyrepo,
	  lazypath 
    })

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end

vim.opt.rtp:prepend(lazypath)

-- Outsource the general vim options to ~/.config/nvim/lua/vim-options.lua
-- IMPORTANT: Leader key has to be set before configuring lazy
require("vim-options")
require("terminal-options")

-- Setup lazy.nvim
--     The string "plugins" will automatically load the plugins from the ~/.config//nvim/lua/plugins directory
--     See https://lazy.folke.io/usage/structuring for more information regarding the structuring of plugins
--
--     If we set the config = function() parameter in the <plugin>.lua file, it will automatically call the
--     require("<pluginname>").setup() function!
require("lazy").setup("plugins")

-- Startup commands
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Your commands here:
    vim.cmd('Neotree filesystem reveal left')
    -- You can also call Lua functions
    --require('telescope.builtin').find_files()
  end,
})

