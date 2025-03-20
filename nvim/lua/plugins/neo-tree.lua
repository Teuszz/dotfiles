return   {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended. DOES REQUIRE NERD FONTS IN TERMINAL?
    "MunifTanjim/nui.nvim",
  },
  config = function()
    vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal left<CR>', {}) -- <CR> simulates pressing Enter after typing that command, otherwise the command would only be inserted into the command line
  end
}

