-- Telescope searches selectable lists with fuzzy matching: files, text, and more.
return {
  {
    -- Pinned to this older release; updating plugins alone will not move this tag.
    'nvim-telescope/telescope.nvim', tag = '0.1.8',
    cmd = "Telescope",
    keys = {
      { "<leader>ff", function() require("telescope.builtin").find_files() end, desc = "Telescope find files" },
      -- live_grep requires the external ripgrep executable ("rg") on PATH.
      { "<leader>fg", function() require("telescope.builtin").live_grep() end, desc = "Telescope live grep" },
    },
    dependencies = { 'nvim-lua/plenary.nvim', 'nvim-telescope/telescope-ui-select.nvim' },
    init = function()
      -- Preserve Telescope selection prompts without loading Telescope at startup.
      -- The first vim.ui.select() loads the plugin and its extension, which replaces
      -- this wrapper before the original selection request is forwarded.
      local function select(items, options, callback)
        require("telescope")
        -- A failed plugin setup must report an error rather than recurse forever.
        if vim.ui.select == select then
          error("Telescope selection UI failed to initialize. See :messages for details.")
        end
        vim.ui.select(items, options, callback)
      end
      vim.ui.select = select
    end,
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
      -- Activate the UI hook after setup, including when loaded by vim.ui.select().
      require("telescope").load_extension("ui-select")
    end
  }
}
