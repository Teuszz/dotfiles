-- Entry point: bootstrap the plugin manager, load editor settings, then load plugins.
-- The current Treesitter plugin requires Neovim 0.12+; fail before installing
-- plugins when an older editor is used instead of producing partial setup errors.
if vim.fn.has("nvim-0.12") == 0 then
  error("This configuration requires Neovim 0.12 or newer.")
end

-- lazy.nvim manages plugins; it is not the LazyVim configuration distribution.
-- stdpath("data") is Neovim's user data directory, separate from this configuration.
-- Clone lazy.nvim's stable branch only when it is not installed yet.
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

  -- Stop on installation failure rather than continuing without a plugin manager.
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

-- Add lazy.nvim to runtimepath so require("lazy") can find its Lua module.
vim.opt.rtp:prepend(lazypath)

-- require() resolves these modules from lua/ inside the configuration directory.
-- Set leader keys before loading plugins so their mappings use the right prefix.
require("vim-options")
require("terminal-options")

-- Import plugin specifications from lua/plugins.lua and lua/plugins/*.lua.
-- Each specification names a repository and optional dependencies/settings.
-- A config function runs when the plugin loads; it must call setup() itself.
-- Using opts = {...} instead lets lazy.nvim call the plugin's setup() automatically.
-- No lazy-loading defaults are overridden here, so plugins load at startup unless
-- their specifications explicitly defer loading. See https://lazy.folke.io/usage/structuring.
require("lazy").setup("plugins")

-- VimEnter runs after startup. Always open the file explorer on the left and
-- reveal the current file, including when Neovim was started with a file argument.
-- This also moves focus away from the Alpha dashboard on an otherwise empty start.
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.cmd('Neotree filesystem reveal left')
  end,
})
