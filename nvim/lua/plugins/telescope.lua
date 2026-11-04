-- Telescope searches selectable lists with fuzzy matching: files, text, and more.
return {
  {
    -- Pinned to this older release; updating plugins alone will not move this tag.
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      -- Space+ff searches file names; Space+fg searches file contents as you type.
      -- live_grep requires the external ripgrep executable ("rg") on PATH.
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
    end
  },
  {
    -- Replace vim.ui.select() prompts with a Telescope picker; this does not
    -- replace every Neovim input prompt or the completion menu.
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            -- Display selection prompts as compact dropdowns.
            require("telescope.themes").get_dropdown {
            }
          }
        }
      }
      -- Installing the extension is not enough; loading it activates the UI hook.
      require("telescope").load_extension("ui-select")
    end
  }
}
