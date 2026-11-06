-- Lualine draws the bottom status line (mode, file details, position, etc.).
-- This is separate from Bufferline's top row of open buffers.
return {
  'nvim-lualine/lualine.nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    -- Catppuccin supplies the status-line theme; initialize it before Lualine.
    { 'catppuccin/nvim', name = 'catppuccin' },
  },
  config = function()
    require('lualine').setup({
      options = {
        -- The Lualine theme name differs from the editor's "catppuccin" alias.
        -- This theme follows the active Catppuccin flavour.
        theme = 'catppuccin-nvim'
      }
    })
  end
}
