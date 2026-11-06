# dotfiles
Config files for programs that i am currently using

## Neovim

The configuration in [nvim/](nvim/) requires Neovim 0.12 or newer and is
maintained for Neovim 0.12.6. It uses the current Treesitter `main` API and
Neovim's native `vim.lsp.config()` API with Mason v2.

For everyday use, see the Neovim cheatsheet in [English](nvim/CHEATSHEET.en.md)
or [German](nvim/CHEATSHEET.de.md), covering editor basics and this configuration's
plugin shortcuts.

### Requirements

- Git for lazy.nvim and plugin installation.
- `ripgrep` (`rg`) for Telescope text searches; `fd` is an optional faster file finder.
- A Nerd Font configured in the terminal for file icons and dashboard artwork.
- Node.js and npm for installing/running the Markdown browser preview, plus a browser.
- A C compiler, `tar`, `curl`, and `tree-sitter-cli` 0.26.1 or newer on `PATH`
  for Treesitter parser installation. Install the CLI through your system
  package manager or Cargo, not npm, as required by nvim-treesitter.
- Internet access on first use to download plugins, parsers, and language servers.
  Mason reports any additional platform-specific tool requirements via
  `:checkhealth mason`.

### Installation and updates

1. Make `nvim/` your Neovim configuration directory (normally `~/.config/nvim`).
   [Choose a Copilot provider](#choosing-a-copilot-provider) before using Copilot.
2. Start Neovim and run `:Lazy restore` to install the plugin revisions recorded
   in [nvim/lazy-lock.json](nvim/lazy-lock.json). Existing setups also need this
   step to switch Treesitter to `main` and update Mason to v2.
3. Restart Neovim after the plugin update. Missing parsers install asynchronously;
   highlighting and indentation activate in open buffers once installation finishes.
   Mason installs and enables `lua_ls`, `clangd`, and `rust_analyzer`.
4. Run `:checkhealth nvim-treesitter mason vim.lsp` to check the installation.

For a first installation, if `~/.config/nvim` does not already exist:

```sh
mkdir -p ~/.config
ln -s /absolute/path/to/dotfiles/nvim ~/.config/nvim
```

Replace the source with your checkout's path. Back up or deliberately merge an
existing configuration first; do not overwrite it blindly.

The Treesitter build hook runs `:TSUpdate` after plugin installation/updates.
You can also run it manually to update existing parsers. Use `:TSLog` to inspect
parser installation errors, `:Mason` to inspect language-server installations,
and `:checkhealth vim.lsp` to inspect enabled/attached language servers.

### Reproducible plugin versions

The version-controlled lockfile records exact plugin commits. Use `:Lazy restore`
after checking out the configuration on another machine or reverting an update.
`:Lazy install` installs missing plugins without updating existing ones;
`:Lazy update` updates plugins within their configured version/branch/tag constraints.
`:Lazy sync` combines installation, updates and removal of plugins no longer configured.
Updates rewrite the lockfile: test the changes and commit the updated lockfile
with the configuration. The lockfile does not pin Mason tools, compilers or system packages.

### Startup and on-demand loading

- `nvim`: show the Alpha dashboard without automatically opening the explorer.
- `nvim file.rs`: edit the file without moving focus to a sidebar.
- `nvim path/to/project`: open Neo-tree for that directory, without changing cwd.
- Multiple arguments and stdin keep Neovim's layout; netrw is disabled in favor
  of Neo-tree. `Space+n` explicitly opens/reveals the current file in the explorer.

Completion loads on the first insert-mode entry. Telescope loads on its command,
its search shortcuts, or the first `vim.ui.select()` prompt; selection prompts
still use its dropdown UI. DAP loads on its debugging shortcuts or `require("dap")`.
Treesitter, the color scheme and basic UI remain startup plugins. Use `:Lazy`
or `:Lazy profile` to inspect loaded plugins and timing.

### LSP navigation and formatting

These mappings are local to buffers with an attached language server and are
removed after the last server detaches:

| Key | Action |
| --- | --- |
| `K` | Hover documentation |
| `gd` / `gD` | Go to definition / declaration |
| `gi` | Go to implementation |
| `Space+ca` | Code actions (normal or visual mode) |
| `Space+cf` | Format the whole buffer using an attached LSP formatter |

Formatting is explicit, never automatically triggered on save. If several servers
support formatting, select one; cancelling makes no changes. Without a formatter
the mapping displays a warning. Formatting times out after three seconds.
Lua's language server can format Lua; clangd typically formats C/C++ and
rust-analyzer delegates Rust formatting to `rustfmt` (install via
`rustup component add rustfmt`). No extra formatting plugin is required.

### Navigation shortcuts

`Space` is the leader prefix: press the listed keys in sequence, not simultaneously.

| Key | Action |
| --- | --- |
| `Space+ff` | Find files with Telescope |
| `Space+fg` | Search file contents with Telescope (`rg` required) |
| `Space+n` | Open/focus Neo-tree and reveal the current file |
| `Space+1` ... `Space+9` | Jump to a buffer by position |
| `Space+$` | Jump to the last buffer |
| `Space+bd` | Close the file buffer while preserving the window layout |
| `Alt+t` | Show/hide the persistent terminal |

`Space+bd` and bufferline's close button/right-click replace the closed file
with the next file buffer, or the previous one, without closing editor splits.
Closing the last file leaves an empty editor buffer beside Neo-tree. Modified
buffers must be saved first; these actions never discard unsaved changes.
The built-in `:bd` command remains unchanged and can close editor windows.
Run `nvim --headless -u NONE -i NONE -l nvim/tests/usability.lua --buffer-closing`
from the repository root to test this behavior without installing plugins.

The editor and status line both use Catppuccin. Lualine explicitly depends on
Catppuccin and uses its `catppuccin-nvim` status-line theme, which follows the
active flavour. This theme name differs from the editor's `catppuccin` alias.

### Completion and snippets

Completion uses language servers and LuaSnip, with words from the current buffer
as a fallback (`cmp-buffer`). Run `:Lazy install` to install missing dependencies
(`:Lazy sync` also updates existing plugins).
Use `Ctrl+l` / `Ctrl+h` to move to the next / previous snippet placeholder.
Outside an active snippet these keys keep their normal behavior. Enter still
accepts the selected suggestion, or the first suggestion if none is selected.

`nvim-autopairs` loads on entering Insert mode and inserts matching brackets
and quotes. Typing an existing closing character skips over it; Backspace
between an empty pair removes both characters. Its nvim-cmp integration adds
parentheses when confirming eligible function/method completions, without
duplicating parentheses already supplied by snippets. Enter's completion/newline
behavior and `Ctrl+l/h` snippet navigation remain unchanged. Pairing is disabled
in Telescope prompts, Copilot chat and the plugin's other default excluded prompts.
Run `:Lazy restore` and restart Neovim to install the locked plugin on other machines.

### Markdown browser preview

[markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) loads
for Markdown files or its commands. Run `:Lazy restore` after updating this
configuration, then restart Neovim. The build hook installs the preview's Node.js
dependencies with npm; Node.js must also remain available when previewing.
If the build fails, inspect the error in `:Lazy`, fix the reported prerequisite
and run `:Lazy build markdown-preview.nvim`.

In a Markdown buffer, use `:MarkdownPreview` to open the live browser preview,
`:MarkdownPreviewStop` to stop it, or `:MarkdownPreviewToggle` to toggle it.
Scrolling is synchronized; the preview closes by default when leaving its buffer.
No browser or preview server starts automatically when opening a Markdown file.

The server listens on localhost only, and its URL is printed in Neovim.
For SSH sessions, forward the port shown in that URL, for example
`ssh -L 8080:127.0.0.1:8080 user@host` (replace both ports with the preview port),
then open the URL in your local browser. The default browser launcher runs on
the Neovim host; do not expose the server to the network to work around this.

### GitHub Copilot

[nvim/lua/plugins/copilot.lua](nvim/lua/plugins/copilot.lua) offers two mutually
exclusive alternatives:

| Selection | Plugins | Features |
| --- | --- | --- |
| `community` | [copilot.lua](https://github.com/zbirenbaum/copilot.lua) + [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim) | Community inline suggestions and chat |
| `official` | [github/copilot.vim](https://github.com/github/copilot.vim) | Official inline suggestions only; no community chat |

#### Choosing a Copilot provider

Create `copilot-local.lua` directly in the Neovim configuration directory
(normally `~/.config/nvim`, or [nvim/](nvim/) when using this checkout).
The file must return exactly one selection:

```lua
-- Community inline suggestions and chat:
return "community"
```

For the official inline-only alternative, use `return "official"` instead.
The local file is Git-ignored; do not put credentials in it. Each installation
chooses independently without modifying the shared plugin specifications.

**There is no default selection.** Without the file, Neovim remains usable,
but all Copilot plugins are disabled and a warning explains how to select one.
Invalid values or invalid Lua produce an explicit configuration error.
After creating or changing the file, restart Neovim and run `:Lazy restore` to
install the selected plugins. Restart again after installation if needed.
Switching providers in a running session is not supported.

Only the selected alternative is installed/loaded by lazy.nvim; its counterpart
has no active commands or mappings. The lockfile records both alternatives and
lazy.nvim preserves disabled plugins' existing lock entries.

Personal accounts and organization-provided accounts hosted on **github.com**
use the default authentication provider. The signed-in account determines Copilot
access, available models and usage limits; no credentials belong in this repository.

**Privacy:** Review the applicable data-sharing policies and
[Copilot account settings](https://github.com/settings/copilot) before use.
Automatic inline suggestions are enabled and send code context while you type.
To disable inline Copilot, use `:Copilot disable`. To request suggestions only
manually, configure
`suggestion.auto_trigger = false` in the `community` provider's options; then
`Alt+]` / `Alt+[` request suggestions manually. This option does not apply to
`copilot.vim`. Disabling inline Copilot does not disable chat in the `community`
alternative. Filetype filters are not a security mechanism.
Do not assume community plugins enforce all content
exclusion rules in the same way as an officially supported client.

#### Requirements and authentication

- A GitHub account with Copilot access through an individual plan or an assigned
  organization seat. For the `community` alternative's chat, **Copilot Chat in the IDE**
  must be enabled in the applicable account/organization settings.
  Complete SSO if required by the organization.
  Enterprise/SSO login links on github.com are not API endpoints.
- **`community`:** Copilot Chat requires **curl 8.0.0+** on `PATH` (check `curl --version`).
  Inline suggestions use the native Copilot Language Server. Node.js is not
  required on Linux x64/arm64 with glibc, macOS or Windows. On first load,
  approximately 75-110 MB is downloaded and verified with SHA-256; Unix systems
  require download, hashing and extraction tools.
- **`official`:** The pinned official plugin requires **Node.js 22+** on `PATH`
  (`node --version`). This alternative does not require CopilotChat or its
  curl/tiktoken dependencies.

1. Run `:Lazy restore` and restart Neovim. The new plugin versions are also
   recorded in the lockfile.
2. Run `:Copilot auth` for `community`, or `:Copilot setup` for `official`, and enter the
   displayed device code in your browser.
   Select the GitHub account with the intended Copilot access. Check the browser's
   active account before authorizing, especially when using multiple accounts.
3. Check `:Copilot status` and test an approved code file in insert mode.
4. **`community` only:** Open `:CopilotChat` and submit a non-confidential test question. Chat may
   display its **own device login**: sign in with the same account used for
   inline suggestions.
   The current chat version reads older Copilot JSON credentials, but not the
   native server's new `auth.db`; a second login is therefore normal.
5. **`community` only:** `:CopilotChatModels` lists the models available to the account. If the default
   model is unavailable under the account's plan or policies,
   select an available model there.

Credentials are managed by the selected Copilot server outside this repository.
For the `community` alternative on Linux, the native server normally uses
`~/.config/github-copilot/auth.db` (or the location under `XDG_CONFIG_HOME`);
CopilotChat stores its own login in `stdpath("data")/copilot_chat/tokens.json`.
Do not commit these files, authentication output, chat histories or logs, or share
them without redaction. Signing into VS Code does not automatically sign you into
Neovim.

#### Account management

Authentication is local to each installation and independent of the shared
configuration and lockfile. Authenticate on each machine; do not sync credential
stores, chat histories or logs.

Git's `user.name`, `user.email` and repository remotes do not select the Copilot
account. Accounts are not switched automatically by repository. Provider
selection also does not select or sign out a GitHub account.
Use `:Copilot auth signout` for `community`, or `:Copilot signout` for `official`.
In the `community` alternative, chat authenticates independently:
`:CopilotChatReset` clears chat history, not chat credentials.

#### Inline suggestions (both alternatives)

| Key / command | Action |
| --- | --- |
| `Alt+l` | Accept an inline suggestion |
| `Alt+]` / `Alt+[` | Next / previous inline suggestion |
| `Ctrl+]` | Dismiss an inline suggestion |

Inline suggestions appear as ghost text. They are hidden while the nvim-cmp menu
is open; Tab, Enter and the existing snippet mappings `Ctrl+l/h` remain unchanged.
Plugins load on demand.

#### Chat (`community` only)

The `official` alternative does not register any of these shortcuts or
commands. CopilotChat is a community integration, not an officially supported
Neovim chat client.

| Key / command | Action |
| --- | --- |
| `Space+ac` | Open/close the chat split (normal or visual mode) |
| `Space+ap` | Select a chat prompt |
| `Space+am` | Select a chat model |
| `Ctrl+s` in chat insert mode / `Enter` in chat normal mode | Submit a question |
| `Ctrl+y` in chat | Apply the suggested diff; review it first |
| `:CopilotChatStop` | Stop the current chat response |
| `:CopilotChatReset` | Reset chat history |

Chat responses default to German. Set `language` in the Copilot plugin options
to change the response language; this does not affect authentication.

Chat sends a request only when you submit a question. The default code context is
the **last visual selection** in the source buffer, including its diagnostics;
without a selection, the whole buffer is not automatically attached. Check the
highlighted selection before submitting. Additional files/resources can be
explicitly added through `#buffer` / `#file` (Tab provides completion).
Tools and project instruction files are not automatically added; explicitly
requested `@Tools` follow the plugin's approval rules. The optional tiktoken
build is not configured, so token counts remain estimates.

#### Troubleshooting

For 401/403 errors or missing models, check the signed-in account, Copilot access,
usage limits and account settings. For organization-provided access, also check
the assigned seat, SSO and policies with an administrator.
For proxy/TLS errors, configure the required proxy and trusted CA certificates;
do not disable certificate verification (`allow_insecure` remains `false`).
CopilotChat supports the `proxy` option; inline suggestions use the Copilot Language
Server's proxy settings. No proxy is configured by default. Keep machine-specific
network settings and credentials out of the shared configuration.
`:Copilot status` helps with either alternative.
For `community`, also use `:checkhealth CopilotChat`.

### Debugging

Install **GDB 14 or newer with Python/DAP support** and ensure `gdb` is on `PATH`.
Mason does not install GDB through this configuration. `:checkhealth dap` checks
adapter executables; a debug launch also reports a missing GDB explicitly.

- In Rust buffers, **Debug Cargo Project** builds binaries and **Debug Cargo Test**
  compiles test executables without running them. Both require Cargo on `PATH`.
- The current file's nearest `Cargo.toml` is used, falling back to the working
  directory's ancestors. Cargo's normal package/workspace defaults apply.
- Builds run asynchronously. Executable paths come from Cargo's JSON artifacts,
  so workspaces, multiple targets, paths with spaces and custom target directories
  do not rely on guessed binary names. Multiple executables open a selection menu;
  cancelling it or a failed build aborts debugging instead of launching a stale binary.
- Rust, C and C++ also provide manual binary launch, process attach and
  `gdbserver` attach profiles. Compile manual binaries with debug symbols (`-g`).
- Cargo program arguments and environment overrides use space-separated prompts,
  not shell quoting; embedded spaces in individual values are not supported.
  Environment overrides preserve inherited variables. Test launches enable Rust backtraces.

`Space+b` toggles a breakpoint. `F5` starts/continues debugging, `F10` steps over
calls, `F11` steps into calls, and `F12` steps out of the current function.

### Terminal

`Alt+t` shows/hides a 15-line terminal split, both from normal and terminal mode.
It reuses the same terminal buffer and shell process, preserving the working
directory, environment and output when hidden or when its window is closed manually.
New terminals use Neovim's `'shell'` setting rather than a hard-coded Bash command.
`Esc` returns to terminal-normal mode without terminating the shell.

Neovim normally closes shells that exit successfully; the next `Alt+t` starts
a fresh shell. If an exited shell's buffer is retained (for example after an
error), the toggle keeps its output available. Use `:bdelete!` on the terminal
buffer to discard it and start fresh on the next toggle.

### Functional regression tests

With Neovim 0.12+ and Cargo installed, run from the repository root:

```sh
nvim --headless -u NONE -i NONE -l nvim/tests/functional.lua
nvim --headless -u NONE -i NONE -l nvim/tests/usability.lua
```

The usability tests also check missing/invalid/local Copilot selections, mutually
exclusive providers, chat context defaults, official mappings and the
nvim-cmp/Copilot visibility handoff without authentication or network requests.
The tests use temporary Cargo workspaces without external crate dependencies and
real terminal jobs. Plugin interfaces are stubbed, so neither installed plugins
nor GDB are required. Temporary files and shell processes are cleaned up afterward.
