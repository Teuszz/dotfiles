-- Neo-tree provides a sidebar for browsing files and directories.
return   {
  "nvim-neo-tree/neo-tree.nvim",
  -- Follow the v3 maintenance branch rather than the repository's default branch.
  branch = "v3.x",
  dependencies = {
    -- Shared Lua utilities used by Neo-tree.
    "nvim-lua/plenary.nvim",
    -- Optional file icons; use a compatible terminal font such as a Nerd Font.
    "nvim-tree/nvim-web-devicons",
    -- UI components used to build the tree's windows and popups.
    "MunifTanjim/nui.nvim",
  },
  config = function()
    -- Space+n opens/focuses the filesystem tree on the left and reveals the file.
    -- This is not a toggle. <CR> executes the command, like pressing Enter.
    -- init.lua also runs this command automatically on startup.
    vim.keymap.set('n', '<leader>n', ':Neotree filesystem reveal left<CR>', {})
  end
}
