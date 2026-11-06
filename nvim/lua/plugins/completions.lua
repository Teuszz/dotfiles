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
      "windwp/nvim-autopairs",
    },
    config = function()
      local cmp = require'cmp'
      local luasnip = require("luasnip")
      local provider = require("copilot-provider").name
      -- cmp uses a custom menu, so each provider needs its own visibility bridge.
      -- Neither bridge loads Copilot or starts a server/network request.
      cmp.event:on("menu_opened", function()
        if provider == "community" then
          vim.b.copilot_suggestion_hidden = true
        elseif provider == "official" then
          -- Temporarily disable suggestions in this buffer, preserving an existing
          -- user override (including false or an unset value) for menu_closed.
          if vim.b.copilot_cmp_saved_disabled == nil then
            vim.b.copilot_cmp_saved_disabled = { value = vim.b.copilot_disabled }
          end
          vim.b.copilot_disabled = true
          if vim.g.loaded_copilot == 1 then
            vim.fn["copilot#Clear"]()
          end
        end
      end)
      cmp.event:on("menu_closed", function()
        if provider == "community" then
          vim.b.copilot_suggestion_hidden = false
        elseif provider == "official" then
          local saved = vim.b.copilot_cmp_saved_disabled
          if saved ~= nil then
            vim.b.copilot_disabled = saved.value
            vim.b.copilot_cmp_saved_disabled = nil
          end
        end
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
      cmp.event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end
  }
}
