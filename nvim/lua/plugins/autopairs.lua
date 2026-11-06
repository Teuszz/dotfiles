-- Insert matching brackets/quotes; completion integration lives in completions.lua.
return {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {
    -- Keep Enter under nvim-cmp's control, including its normal newline fallback.
    map_cr = false,
    disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input", "copilot-chat" },
  },
}
