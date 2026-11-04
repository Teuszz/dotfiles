-- Lualine draws the bottom status line (mode, file details, position, etc.).
-- This is separate from Bufferline's top row of open buffers.
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        -- Lualine ships its own Dracula palette; it does not change the editor
        -- color scheme. This differs from Catppuccin in this config.
        theme = 'dracula' 
      }
    })
  end
}
