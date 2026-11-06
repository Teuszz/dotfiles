-- Read one explicit, installation-local choice before lazy.nvim resolves plugins.
-- The file returns "community" (inline + chat) or "official" (official inline only).
local path = vim.fn.stdpath("config") .. "/copilot-local.lua"
local stat, stat_error, error_code = vim.uv.fs_stat(path)
if not stat then
  if error_code ~= "ENOENT" then
    error("Cannot read Copilot selection at " .. path .. ": " .. tostring(stat_error))
  end
  -- Keep the editor usable, but never silently select a provider or send code.
  vim.schedule(function()
    vim.notify(
      'Copilot is disabled. Create ' .. path .. ' returning "community" or "official", then restart Neovim.',
      vim.log.levels.WARN
    )
  end)
  return {}
end

local load_choice, load_error = loadfile(path)
if not load_choice then
  error("Invalid Copilot selection file " .. path .. ": " .. load_error)
end
local name = load_choice()
if name ~= "community" and name ~= "official" then
  error('Invalid Copilot selection in ' .. path .. ': expected "community" or "official".')
end

-- require() caches this value so plugin loading and completion use the same choice.
return { name = name }
