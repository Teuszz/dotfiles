-- Lualine draws the bottom status line (mode, file details, position, etc.).
-- This is separate from Bufferline's top row of open buffers.
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        -- Match the editor's Catppuccin scheme instead of using a separate palette.
        theme = 'catppuccin'
      }
    })
  end
}
