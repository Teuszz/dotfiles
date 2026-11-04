-- Display open buffers across the top. Buffers are loaded files, not Neovim
-- tab pages (which are separate window layouts); this uses the default buffer mode.
return {
  'akinsho/bufferline.nvim',
  -- Select a tagged release matching any version, rather than the latest commit.
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    -- Allow RGB colors in terminals that support true color.
    vim.opt.termguicolors = true
    require("bufferline").setup{
      options = {
        -- Show positions in the buffer list, not internal buffer IDs.
        -- See :help bufferline-configuration for additional options.
        numbers = "ordinal",
        -- Add diagnostic counts from Neovim's language-server client.
        diagnostics = "nvim_lsp",
        -- Reserve a labeled area above Neo-tree instead of drawing file tabs there.
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true
          }
        },
        -- Use colored filetype icons supplied by nvim-web-devicons.
        color_icons = true,
        show_buffer_icons = true,
      }
    }
      -- Space+1 through Space+9 jump by position in the full buffer list (true),
      -- not just the portion currently visible. Space+$ jumps to the last entry (-1).
      vim.keymap.set('n', '<leader>1', '<cmd>lua require("bufferline").go_to(1, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>2', '<cmd>lua require("bufferline").go_to(2, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>3', '<cmd>lua require("bufferline").go_to(3, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>4', '<cmd>lua require("bufferline").go_to(4, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>5', '<cmd>lua require("bufferline").go_to(5, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>6', '<cmd>lua require("bufferline").go_to(6, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>7', '<cmd>lua require("bufferline").go_to(7, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>8', '<cmd>lua require("bufferline").go_to(8, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>9', '<cmd>lua require("bufferline").go_to(9, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>$', '<cmd>lua require("bufferline").go_to(-1, true)<cr>', { silent = true })
  end
}
