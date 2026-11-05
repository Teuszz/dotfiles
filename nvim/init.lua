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
-- UI essentials and Treesitter load at startup; expensive tools declare their own
-- event/command/key triggers. Keep global defaults unchanged to avoid hidden dependencies.
-- lazy.nvim reads lazy-lock.json from the configuration directory; :Lazy restore
-- restores its recorded commits, while :Lazy update deliberately rewrites them.
require("lazy").setup("plugins")

-- A plain start keeps Alpha; file arguments keep focus on the file. Only an
-- explicit directory argument opens Neo-tree, without changing the working directory.
require("startup").setup()
