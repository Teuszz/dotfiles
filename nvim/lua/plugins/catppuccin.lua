-- Catppuccin supplies the editor's color scheme.
return {
  "catppuccin/nvim",
  -- Give this plugin an unambiguous name instead of the repository name "nvim".
  name = "catppuccin",
  -- Load the color scheme before most other startup plugins to avoid color flashes.
  priority = 1000,
  config = function()
    -- No flavour is specified, so the plugin's default is used.
    vim.cmd.colorscheme "catppuccin"
  end
}
