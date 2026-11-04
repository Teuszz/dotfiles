-- Tree-sitter parsers understand syntax structure, enabling more precise
-- highlighting and syntax-aware indentation than text patterns alone.
-- Parsers are separate from LSP servers and do not provide completion/diagnostics.
-- Compatibility: this is the legacy nvim-treesitter.configs API. The current main
-- branch is an incompatible rewrite; this setup needs migration or an explicit
-- legacy master branch pin before it can work with a fresh current installation.
return {
  "nvim-treesitter/nvim-treesitter",
  -- Run after plugin installation/updates so parser versions match the plugin.
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      -- Install syntax parsers for source files, build files and documentation.
      ensure_installed = { "c", "cpp", "cmake", "rust", "toml", "lua", "markdown" },
      -- Install missing parsers asynchronously rather than waiting at startup.
      sync_install = false,
      -- Use parser-based highlighting and indentation (the latter can vary by language).
      highlight = { enable = true },
      indent = { enable = true },  
    })
  end
}
