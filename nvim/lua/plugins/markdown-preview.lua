-- Render Markdown in a browser only when explicitly requested.
return {
  "iamcco/markdown-preview.nvim",
  ft = { "markdown" },
  cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
  build = "cd app && npm install --omit=dev --no-audit --no-fund",
  init = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_auto_start = 0
    vim.g.mkdp_open_to_the_world = 0
    -- Also make the URL available for remote sessions with SSH port forwarding.
    vim.g.mkdp_echo_preview_url = 1
  end,
}
