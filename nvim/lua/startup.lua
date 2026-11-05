local M = {}

function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("ConfiguredStartup", { clear = true }),
    once = true,
    callback = function()
      -- Ignore mixed file/directory arguments and stdin, preserving Neovim's layout.
      if vim.fn.argc() ~= 1 then
        return
      end
      local directory = vim.fn.fnamemodify(vim.fn.argv(0), ":p")
      if vim.fn.isdirectory(directory) == 1 then
        require("neo-tree.command").execute({
          action = "focus", source = "filesystem", position = "left", dir = directory,
        })
      end
    end,
  })
end

return M
