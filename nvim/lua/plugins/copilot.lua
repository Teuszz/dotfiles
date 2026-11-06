-- Two separate interfaces: copilot.lua provides inline code suggestions,
-- while CopilotChat.nvim provides chat. The same setup supports personal and
-- organization-provided GitHub accounts; authenticate locally on each machine.
-- Both are community plugins; applicable policies must permit their use and
-- the transmission of code.
return {
  {
    "zbirenbaum/copilot.lua",
    main = "copilot",
    -- Load when entering insert mode or running :Copilot, not at editor startup.
    event = "InsertEnter",
    cmd = "Copilot",
    opts = {
      -- Personal and organization-provided accounts on github.com use the same
      -- provider. :Copilot auth signs in whichever account you select in the browser.
      -- Enterprise/SSO links are not API endpoints. Leave auth_provider_url at
      -- its default (github.com); no account name or token is needed here.
      -- The native server does not require Node.js on supported Linux systems.
      -- On first load, it downloads a version-pinned, SHA-256-verified binary.
      server = { type = "binary" },
      -- Avoid a second suggestion list: nvim-cmp still handles LSP/snippets.
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        -- Deliberately enabled: typing sends code context to Copilot.
        -- Set to false to request suggestions only with Alt+] / Alt+[.
        auto_trigger = true,
        hide_during_completion = true,
        -- Keep Tab, Enter and Ctrl+l/h available for completion and snippets.
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      -- Disable inline suggestions in help, commit messages and chat.
      -- This is a convenience setting, NOT protection for confidential files.
      filetypes = {
        help = false,
        gitcommit = false,
        gitrebase = false,
        ["copilot-chat"] = false,
      },
    },
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    main = "CopilotChat",
    -- Reuse Plenary, which is already required by other plugins.
    -- Chat authenticates independently; copilot.lua is not a dependency here.
    -- Select the same GitHub account for both plugins.
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = {
      "CopilotChat", "CopilotChatOpen", "CopilotChatClose", "CopilotChatToggle",
      "CopilotChatStop", "CopilotChatReset", "CopilotChatSave", "CopilotChatLoad",
      "CopilotChatPrompts", "CopilotChatModels",
    },
    -- Space, a, c only opens chat; it does not submit a request.
    -- In visual mode, the selection becomes context when a prompt is submitted.
    keys = {
      { "<leader>ac", "<cmd>CopilotChatToggle<CR>", mode = { "n", "x" }, desc = "Copilot: Toggle chat" },
      { "<leader>ap", "<cmd>CopilotChatPrompts<CR>", desc = "Copilot: Select prompt" },
      { "<leader>am", "<cmd>CopilotChatModels<CR>", desc = "Copilot: Select model" },
    },
    opts = {
      -- Do not hard-code a model: :CopilotChatModels lists the models actually
      -- available to the signed-in account under its plan and applicable policies.
      language = "German",
      window = { layout = "vertical", width = 0.4 },
      -- Use only the visual selection as default code context, not all files.
      -- Additional resources can be explicitly added with #buffer / #file.
      selection = "visual",
      resources = { "selection" },
      -- Do not automatically add tools or project instructions as context.
      -- Explicit @Tools still follow the plugin's approval rules.
      tools = {},
      instruction_files = {},
      -- Keep certificate verification enabled, including behind a proxy.
      allow_insecure = false,
      -- tiktoken is optional; no build hook or new compiler dependency is required.
    },
  },
}
