-- Display open buffers across the top. Buffers are loaded files, not Neovim
-- tab pages (which are separate window layouts); this uses the default buffer mode.

-- Close the given file buffer (or the current one) without losing the window layout.
-- Replace it in every window with a neighboring file buffer, another available file
-- buffer, or an empty buffer if none remain. Refuse buffers with unsaved changes.
local function close_buffer(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(buf) or not vim.bo[buf].buflisted or vim.bo[buf].buftype ~= "" then
    vim.notify("Select a listed file buffer to close.", vim.log.levels.WARN)
    return
  end
  if vim.bo[buf].modified then
    vim.notify("Buffer has unsaved changes. Save it before closing.", vim.log.levels.WARN)
    return
  end

  local function available(id)
    return id ~= buf and vim.api.nvim_buf_is_valid(id)
      and vim.bo[id].buflisted and vim.bo[id].buftype == ""
  end
  local elements = require("bufferline").get_elements().elements
  local index, replacement
  for i, element in ipairs(elements) do
    if element.id == buf then index = i break end
  end
  if index then
    for i = index + 1, #elements do
      if available(elements[i].id) then replacement = elements[i].id break end
    end
    if not replacement then
      for i = index - 1, 1, -1 do
        if available(elements[i].id) then replacement = elements[i].id break end
      end
    end
  end
  -- The tabline may not have redrawn yet after a buffer was opened or closed.
  if not replacement then
    for _, id in ipairs(vim.api.nvim_list_bufs()) do
      if available(id) then replacement = id break end
    end
  end

  local windows = {}
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then windows[#windows + 1] = win end
  end
  if #windows > 0 then
    replacement = replacement or vim.api.nvim_create_buf(true, false)
    for _, win in ipairs(windows) do
      vim.api.nvim_win_set_buf(win, replacement)
    end
  end
  if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = false }) end
end

return {
  'akinsho/bufferline.nvim',
  -- Select a tagged release matching any version, rather than the latest commit.
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons',
  config = function()
    -- Allow RGB colors in terminals that support true color.
    vim.opt.termguicolors = true
    require("bufferline").setup{
      options = {
        close_command = close_buffer,
        right_mouse_command = close_buffer,
        -- Show positions in the buffer list, not internal buffer IDs.
        -- See :help bufferline-configuration for additional options.
        numbers = "ordinal",
        -- Add diagnostic counts from Neovim's language-server client.
        diagnostics = "nvim_lsp",
        -- Reserve a labeled area above Neo-tree instead of drawing file tabs there.
        offsets = {
          {
            filetype = "neo-tree",
            text = "File Explorer",
            text_align = "center",
            separator = true
          }
        },
        -- Use colored filetype icons supplied by nvim-web-devicons.
        color_icons = true,
        show_buffer_icons = true,
      }
    }
      -- Space+1 through Space+9 jump by position in the full buffer list (true),
      -- not just the portion currently visible. Space+$ jumps to the last entry (-1).
      vim.keymap.set('n', '<leader>1', '<cmd>lua require("bufferline").go_to(1, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>2', '<cmd>lua require("bufferline").go_to(2, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>3', '<cmd>lua require("bufferline").go_to(3, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>4', '<cmd>lua require("bufferline").go_to(4, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>5', '<cmd>lua require("bufferline").go_to(5, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>6', '<cmd>lua require("bufferline").go_to(6, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>7', '<cmd>lua require("bufferline").go_to(7, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>8', '<cmd>lua require("bufferline").go_to(8, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>9', '<cmd>lua require("bufferline").go_to(9, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>$', '<cmd>lua require("bufferline").go_to(-1, true)<cr>', { silent = true })
      vim.keymap.set('n', '<leader>bd', function() close_buffer() end, {
        silent = true, desc = "Close buffer without closing windows",
      })
  end
}
