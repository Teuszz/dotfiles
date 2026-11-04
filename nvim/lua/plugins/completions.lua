-- Completion pipeline: sources provide suggestions, nvim-cmp displays them,
-- and LuaSnip expands snippet placeholders after a suggestion is accepted.
return {
  {
    -- Bridges LSP completion into nvim-cmp and exposes default_capabilities(),
    -- which lsp-config.lua sends to servers to advertise completion support.
    "hrsh7th/cmp-nvim-lsp"
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      -- Snippet engine, its completion source, and a collection of ready-made snippets.
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require'cmp'
      -- Load VS Code-format snippets, including the friendly-snippets collection.
      require("luasnip.loaders.from_vscode").load()

      cmp.setup({
        snippet = {
          -- LSP suggestions can contain snippet syntax; LuaSnip interprets it.
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        -- Give both the suggestions and their documentation a visible border.
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- Extend cmp's insert-mode defaults: Ctrl+b/f scroll documentation,
        -- Ctrl+Space requests suggestions, and Ctrl+e closes completion.
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          -- Enter accepts the selected item, or the first item if none is selected.
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        -- Prefer LSP and snippet sources. Use the buffer source as a fallback group
        -- when the first group has no suggestions. NOTE: cmp-buffer is not declared
        -- in this configuration, so the buffer source cannot currently supply items.
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        }, {
            { name = 'buffer' },
          })
      })
    end
  }
}
