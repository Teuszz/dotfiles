-- Language Server Protocol (LSP) separates editor UI from language intelligence.
-- Servers provide diagnostics, navigation and code actions; Neovim is the client.
-- Completion menus are configured separately in completions.lua.
return {
  {
    -- Mason's bridge installs and enables servers using Neovim's native LSP API.
    -- Stay on the v2 API series; both Mason repositories now live under mason-org.
    "mason-org/mason-lspconfig.nvim",
    version = "^2.0.0",
    -- lazy.nvim loads/configures these dependencies before running this callback.
    dependencies = {
      -- Mason installs tools into Neovim's data directory and adds them to PATH.
      { "mason-org/mason.nvim", version = "^2.0.0", opts = {} },
      -- Supplies server defaults, including filetypes and project-root detection.
      "neovim/nvim-lspconfig",
      -- Supplies completion capabilities shared with nvim-cmp in completions.lua.
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local servers = { "lua_ls", "clangd", "rust_analyzer" }
      -- Advertise completion features understood by nvim-cmp, including snippets.
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Extend nvim-lspconfig's defaults through the native API before any server
      -- is enabled. No require("lspconfig") or legacy <server>.setup() is needed.
      for _, server in ipairs(servers) do
        vim.lsp.config(server, { capabilities = capabilities })
      end

      require("mason-lspconfig").setup({
        -- Install Lua, C/C++ and Rust language servers, not compilers or debuggers.
        ensure_installed = servers,
        -- Mason calls vim.lsp.enable() for these servers after installation,
        -- including servers installed later in this session. Restrict activation
        -- to this list so unrelated Mason installations do not change behavior.
        automatic_enable = servers,
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
