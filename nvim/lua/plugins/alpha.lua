-- Alpha provides a startup dashboard, not a file explorer or session manager.
return {
  "goolord/alpha-nvim",
  dependencies = {
    -- File icons require a compatible font, typically a Nerd Font, in the terminal.
    "nvim-tree/nvim-web-devicons",
  },

  config = function()
    local alpha = require("alpha")
    -- Startify supplies a dashboard layout with recent-file shortcuts.
    local dashboard = require("alpha.themes.startify")

    -- Replace only the header artwork; keep the theme's remaining sections.
    dashboard.section.header.val = {
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                     ]],
      [[       ████ ██████           █████      ██                     ]],
      [[      ███████████             █████                             ]],
      [[      █████████ ███████████████████ ███   ███████████   ]],
      [[     █████████  ███    █████████████ █████ ██████████████   ]],
      [[    █████████ ██████████ █████████ █████ █████ ████ █████   ]],
      [[  ███████████ ███    ███ █████████ █████ █████ ████ █████  ]],
      [[ ██████  █████████████████████ ████ █████ █████ ████ ██████ ]],
      [[                                                                       ]],
      [[                                                                       ]],
      [[                                                                       ]],
    }

    -- Register the dashboard. init.lua also opens Neo-tree on VimEnter.
    alpha.setup(dashboard.opts)
  end,
}
