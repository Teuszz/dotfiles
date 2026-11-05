-- Neo-tree provides a sidebar for browsing files and directories.
return   {
  "nvim-neo-tree/neo-tree.nvim",
  -- Follow the v3 maintenance branch rather than the repository's default branch.
  branch = "v3.x",
  -- Commands and key stubs load the explorer only when requested.
  cmd = "Neotree",
  keys = {
    { "<leader>n", "<cmd>Neotree filesystem reveal left<cr>", desc = "Explorer reveal current file" },
  },
  init = function()
    -- Neo-tree handles explicit directory starts; do not let netrw open a competing UI.
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end,
  dependencies = {
    -- Shared Lua utilities used by Neo-tree.
    "nvim-lua/plenary.nvim",
    -- Optional file icons; use a compatible terminal font such as a Nerd Font.
    "nvim-tree/nvim-web-devicons",
    -- UI components used to build the tree's windows and popups.
    "MunifTanjim/nui.nvim",
  },
  -- startup.lua owns directory handling; disable a competing netrw hijack.
  -- Space+n reveals rather than toggles the explorer.
  opts = {
    filesystem = {
      hijack_netrw_behavior = "disabled",
      -- Browsing directories must not silently change terminal/build/search cwd.
      bind_to_cwd = false,
    },
  },
}
