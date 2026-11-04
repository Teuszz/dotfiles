-- Language Server Protocol (LSP) separates editor UI from language intelligence.
-- Servers provide diagnostics, navigation and code actions; Neovim is the client.
-- Completion menus are configured separately in completions.lua.
return {
  {
    -- Mason installs external developer tools into Neovim's data directory and
    -- exposes their executables on PATH. It does not configure LSP behavior itself.
    -- These repository names predate the move to the mason-org organization.
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end
  },
  -- Bridge Mason's package names to nvim-lspconfig's server identifiers.
  -- Modern mason-lspconfig also enables installed servers by default. Its setup
  -- requires Mason to be set up and nvim-lspconfig to be on runtimepath; this
  -- configuration does not yet declare those ordering requirements as dependencies.
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        -- Install servers for Lua, C/C++, and Rust. This installs the language
        -- servers, not the corresponding compilers, Cargo, or a debugger.
        ensure_installed = { "lua_ls", "clangd", "rust_analyzer"}
      })
    end
  },
  -- nvim-lspconfig provides server-specific defaults such as filetypes/root detection.
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Advertise completion features understood by nvim-cmp, including snippets.
      local capabilities = require('cmp_nvim_lsp').default_capabilities()
      -- Legacy API: require("lspconfig").<server>.setup() is deprecated.
      -- Neovim 0.11+ uses vim.lsp.config() and vim.lsp.enable() instead.
      -- Kept unchanged here; adding documentation does not migrate the LSP setup.
      local lspconfig = require('lspconfig')

      lspconfig.lua_ls.setup({
        capabilities = capabilities
      })
      lspconfig.clangd.setup({
        capabilities = capabilities
      })
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities
      })

      -- Normal-mode navigation: K = documentation, gd = definition,
      -- gD = declaration, gi = implementation. Space+ca requests code actions
      -- in normal or visual mode. See :help vim.lsp.buf.
      -- These mappings are global, even in buffers without an attached server.
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, {})
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, {})
      vim.keymap.set({ 'n', 'v'}, '<leader>ca', vim.lsp.buf.code_action, {})
    end
  }
}
