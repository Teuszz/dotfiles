-- Tree-sitter parsers understand syntax structure, enabling more precise
-- highlighting and syntax-aware indentation than text patterns alone.
-- Parsers are separate from LSP servers and do not provide completion/diagnostics.
return {
  "nvim-treesitter/nvim-treesitter",
  -- Use the rewritten API for Neovim 0.12+. Treesitter does not support lazy-loading.
  branch = "main",
  lazy = false,
  -- Run after plugin installation/updates so parser versions match the plugin.
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter")
    local parsers = { "c", "cpp", "cmake", "rust", "toml", "lua", "markdown" }
    -- Create the parser location before adding it to runtimepath. Neovim can cache
    -- nonexistent runtime directories, otherwise hiding new parsers until restart.
    local install_dir = vim.fn.stdpath("data") .. "/site"
    vim.fn.mkdir(install_dir, "p")
    treesitter.setup({ install_dir = install_dir })
    local installing = true

    -- Highlighting is now provided by Neovim, while this plugin supplies indentexpr.
    -- Only enable these features for our configured languages with installed parsers.
    local function attach(buf)
      local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
      if not vim.list_contains(parsers, lang) then
        return
      end

      -- Wait until libraries AND queries have finished copying before loading them.
      -- The callback below revisits open buffers; failed installations are reported
      -- there, and buffers without a successfully installed parser stay unchanged.
      if installing or not vim.list_contains(treesitter.get_installed("parsers"), lang) then
        return
      end

      vim.treesitter.start(buf, lang)
      -- Tree-sitter indentation is experimental and may behave differently by language.
      vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("ConfiguredTreesitter", { clear = true }),
      callback = function(event)
        attach(event.buf)
      end,
    })

    -- install() replaces ensure_installed and skips parsers that are already present.
    -- Keep startup responsive, then enable features without requiring files to reopen.
    treesitter.install(parsers):await(vim.schedule_wrap(function(err, success)
      installing = false
      if err or not success then
        vim.notify(
          "Tree-sitter parser installation failed. See :TSLog for details."
            .. (err and ("\n" .. tostring(err)) or ""),
          vim.log.levels.ERROR
        )
      end

      -- Successful parsers remain usable even if another language failed to install.
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) then
          attach(buf)
        end
      end
    end))
  end
}
