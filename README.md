# dotfiles
Config files for programs that i am currently using

## Neovim

The configuration in [nvim/](nvim/) requires Neovim 0.12 or newer and is
maintained for Neovim 0.12.6. It uses the current Treesitter `main` API and
Neovim's native `vim.lsp.config()` API with Mason v2.

### Requirements

- Git for lazy.nvim and plugin installation.
- A C compiler, `tar`, `curl`, and `tree-sitter-cli` 0.26.1 or newer on `PATH`
  for Treesitter parser installation. Install the CLI through your system
  package manager or Cargo, not npm, as required by nvim-treesitter.
- Internet access on first use to download plugins, parsers, and language servers.
  Mason reports any additional platform-specific tool requirements via
  `:checkhealth mason`.

### Installation and updates

1. Make `nvim/` your Neovim configuration directory (normally `~/.config/nvim`).
2. Start Neovim and run `:Lazy sync` to install/update plugins. Existing setups
   also need this step to switch Treesitter to `main` and update Mason to v2.
3. Restart Neovim after the plugin update. Missing parsers install asynchronously;
   highlighting and indentation activate in open buffers once installation finishes.
   Mason installs and enables `lua_ls`, `clangd`, and `rust_analyzer`.
4. Run `:checkhealth nvim-treesitter mason vim.lsp` to check the installation.

The Treesitter build hook runs `:TSUpdate` after plugin installation/updates.
You can also run it manually to update existing parsers. Use `:TSLog` to inspect
parser installation errors, `:Mason` to inspect language-server installations,
and `:checkhealth vim.lsp` to inspect enabled/attached language servers.
