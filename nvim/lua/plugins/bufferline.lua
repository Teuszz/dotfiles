return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    vim.opt.termguicolors = true
    require("bufferline").setup{
      options = {
        -- see :h bufferline-configuration
        numbers = "ordinal",
        diagnostics = "nvim_lsp",
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true
          }
        },
        color_icons = true,
        show_buffer_icons = true,
      }
    }
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
