-- Register before enabling servers so the first LspAttach event is never missed.
local M = {}

function M.setup()
  local group = vim.api.nvim_create_augroup("ConfiguredLsp", { clear = true })
  local mappings = {
    { "K", vim.lsp.buf.hover, "LSP hover documentation" },
    { "gd", vim.lsp.buf.definition, "LSP go to definition" },
    { "gD", vim.lsp.buf.declaration, "LSP go to declaration" },
    { "gi", vim.lsp.buf.implementation, "LSP go to implementation" },
    { "<leader>ca", vim.lsp.buf.code_action, "LSP code action", { "n", "x" } },
  }

  local function format(buf)
    local clients = vim.lsp.get_clients({ bufnr = buf, method = "textDocument/formatting" })
    if #clients == 0 then
      vim.notify("No attached language server supports formatting this buffer.", vim.log.levels.WARN)
      return
    end
    local function apply(client)
      if client and vim.api.nvim_buf_is_valid(buf) then
        -- Format only with the selected client, never sequentially with every server.
        -- Keep this explicit and synchronous: saving does not trigger formatting.
        if not vim.lsp.buf_is_attached(buf, client.id) then
          vim.notify("The selected formatter detached. Please try again.", vim.log.levels.WARN)
          return
        end
        vim.lsp.buf.format({ bufnr = buf, id = client.id, async = false, timeout_ms = 3000 })
      end
    end
    if #clients == 1 then
      apply(clients[1])
    else
      table.sort(clients, function(a, b) return a.id < b.id end)
      vim.ui.select(clients, {
        prompt = "Select LSP formatter:",
        format_item = function(client) return client.name .. " (" .. client.id .. ")" end,
      }, apply)
    end
  end

  vim.api.nvim_create_autocmd("LspAttach", {
    group = group,
    callback = function(event)
      for _, mapping in ipairs(mappings) do
        vim.keymap.set(mapping[4] or "n", mapping[1], mapping[2], {
          buffer = event.buf, silent = true, desc = mapping[3],
        })
      end
      vim.keymap.set("n", "<leader>cf", function() format(event.buf) end, {
        buffer = event.buf, silent = true, desc = "LSP format buffer",
      })
    end,
  })

  -- Defer cleanup because the departing client is still attached during LspDetach.
  vim.api.nvim_create_autocmd("LspDetach", {
    group = group,
    callback = function(event)
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(event.buf) or #vim.lsp.get_clients({ bufnr = event.buf }) > 0 then
          return
        end
        -- Neovim may already remove built-in LSP maps on detach. Delete only our
        -- remaining maps, leaving any user/plugin replacements intact.
        local descriptions = { ["LSP format buffer"] = true }
        for _, mapping in ipairs(mappings) do descriptions[mapping[3]] = true end
        for _, mode in ipairs({ "n", "x" }) do
          for _, mapping in ipairs(vim.api.nvim_buf_get_keymap(event.buf, mode)) do
            if descriptions[mapping.desc] then
              vim.keymap.del(mode, mapping.lhs, { buffer = event.buf })
            end
          end
        end
      end)
    end,
  })
end

return M
