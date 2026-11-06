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
    -- Load the menu on first insert; cmp-nvim-lsp stays available to LSP setup.
    event = "InsertEnter",
    dependencies = {
      -- Snippet engine, its completion source, and a collection of ready-made snippets.
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
      -- Implements the "buffer" source configured below (words from the current buffer).
      "hrsh7th/cmp-buffer",
    },
    config = function()
      local cmp = require'cmp'
      local luasnip = require("luasnip")
      -- Hide Copilot ghost text while the cmp menu is visible.
      -- This buffer variable works even before Copilot is lazy-loaded;
      -- setting it does not load the plugin or initiate a network request.
      cmp.event:on("menu_opened", function()
        vim.b.copilot_suggestion_hidden = true
      end)
      cmp.event:on("menu_closed", function()
        vim.b.copilot_suggestion_hidden = false
      end)
      -- Load VS Code-format snippets, including the friendly-snippets collection.
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          -- LSP suggestions can contain snippet syntax; LuaSnip interprets it.
          expand = function(args)
            luasnip.lsp_expand(args.body)
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
          -- Ctrl+l/h move between snippet placeholders in insert/select mode.
          -- Outside the active snippet, preserve the keys' normal behavior.
          ['<C-l>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function(fallback)
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
          -- Enter accepts the selected item, or the first item if none is selected.
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        -- Prefer LSP and snippet sources. Use the buffer source as a fallback group
        -- when the first group has no suggestions.
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
