# dotfiles
Config files for programs that i am currently using

## Neovim

The configuration in [nvim/](nvim/) requires Neovim 0.12 or newer and is
maintained for Neovim 0.12.6. It uses the current Treesitter `main` API and
Neovim's native `vim.lsp.config()` API with Mason v2.

### Requirements

- Git for lazy.nvim and plugin installation.
- `ripgrep` (`rg`) for Telescope text searches; `fd` is an optional faster file finder.
- A Nerd Font configured in the terminal for file icons and dashboard artwork.
- A C compiler, `tar`, `curl`, and `tree-sitter-cli` 0.26.1 or newer on `PATH`
  for Treesitter parser installation. Install the CLI through your system
  package manager or Cargo, not npm, as required by nvim-treesitter.
- Internet access on first use to download plugins, parsers, and language servers.
  Mason reports any additional platform-specific tool requirements via
  `:checkhealth mason`.

### Installation and updates

1. Make `nvim/` your Neovim configuration directory (normally `~/.config/nvim`).
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
| `Alt+t` | Show/hide the persistent terminal |

The editor and status line both use Catppuccin.

### Completion and snippets

Completion uses language servers and LuaSnip, with words from the current buffer
as a fallback (`cmp-buffer`). Run `:Lazy install` to install missing dependencies
(`:Lazy sync` also updates existing plugins).
Use `Ctrl+l` / `Ctrl+h` to move to the next / previous snippet placeholder.
Outside an active snippet these keys keep their normal behavior. Enter still
accepts the selected suggestion, or the first suggestion if none is selected.

### GitHub Copilot

[nvim/lua/plugins/copilot.lua](nvim/lua/plugins/copilot.lua) configures two
community plugins: [copilot.lua](https://github.com/zbirenbaum/copilot.lua) for
inline code suggestions and [CopilotChat.nvim](https://github.com/CopilotC-Nvim/CopilotChat.nvim)
for chat. This is not an officially GitHub-supported Neovim chat integration.

Personal accounts and organization-provided accounts hosted on **github.com**
use the default authentication provider. The signed-in account determines Copilot
access, available models and usage limits; no credentials belong in this repository.

**Privacy:** Review the applicable data-sharing policies and
[Copilot account settings](https://github.com/settings/copilot) before use.
Automatic inline suggestions are enabled and send code context while you type.
To disable inline Copilot, use `:Copilot disable`. To request suggestions only
manually, configure
`suggestion.auto_trigger = false`; then `Alt+]` / `Alt+[` request suggestions
manually. This does not disable the separate chat plugin. Filetype filters are
not a security mechanism. Do not assume community plugins enforce all content
exclusion rules in the same way as an officially supported client.

#### Requirements and authentication

- A GitHub account with Copilot access through an individual plan or an assigned
  organization seat. **Copilot Chat in the IDE** must be enabled in the applicable
  account/organization settings. Complete SSO if required by the organization.
  Enterprise/SSO login links on github.com are not API endpoints.
- Copilot Chat requires **curl 8.0.0+** on `PATH` (check `curl --version`).
- Inline suggestions use the native Copilot Language Server. Node.js is not
  required on Linux x64/arm64 with glibc, macOS or Windows. On first load,
  approximately 75-110 MB is downloaded and verified with SHA-256; Unix systems
  require download, hashing and extraction tools.

1. Run `:Lazy restore` and restart Neovim. The new plugin versions are also
   recorded in the lockfile.
2. Run `:Copilot auth` and enter the displayed device code in your browser.
   Select the GitHub account with the intended Copilot access. Check the browser's
   active account before authorizing, especially when using multiple accounts.
3. Check `:Copilot status` and test an approved code file in insert mode.
4. Open `:CopilotChat` and submit a non-confidential test question. Chat may
   display its **own device login**: sign in with the same account used for
   inline suggestions.
   The current chat version reads older Copilot JSON credentials, but not the
   native server's new `auth.db`; a second login is therefore normal.
5. `:CopilotChatModels` lists the models available to the account. If the default
   model is unavailable under the account's plan or policies,
   select an available model there.

Credentials remain outside this repository: on Linux, the native server normally
uses `~/.config/github-copilot/auth.db` (or the location under `XDG_CONFIG_HOME`);
chat stores its own login in `stdpath("data")/copilot_chat/tokens.json`.
Do not commit these files, authentication output, chat histories or logs, or share
them without redaction. Signing into VS Code does not automatically sign you into
Neovim.

#### Account management

Authentication is local to each installation and independent of the shared
configuration and lockfile. Authenticate on each machine; do not sync credential
stores, chat histories or logs.

Git's `user.name`, `user.email` and repository remotes do not select the Copilot
account. Accounts are not switched automatically by repository. When changing
accounts, check both plugins: `:Copilot auth signout` signs out only the inline
plugin, while `:CopilotChatReset` clears chat history, not chat credentials.

#### Usage

| Key / command | Action |
| --- | --- |
| `Alt+l` | Accept an inline suggestion |
| `Alt+]` / `Alt+[` | Next / previous inline suggestion |
| `Ctrl+]` | Dismiss an inline suggestion |
| `Space+ac` | Open/close the chat split (normal or visual mode) |
| `Space+ap` | Select a chat prompt |
| `Space+am` | Select a chat model |
| `Ctrl+s` in chat insert mode / `Enter` in chat normal mode | Submit a question |
| `Ctrl+y` in chat | Apply the suggested diff; review it first |
| `:CopilotChatStop` | Stop the current chat response |
| `:CopilotChatReset` | Reset chat history |

Inline suggestions appear as ghost text. They are hidden while the nvim-cmp menu
is open; Tab, Enter and the existing snippet mappings `Ctrl+l/h` remain unchanged.
Both plugins load on demand.

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
Chat supports the `proxy` option; inline suggestions use the Copilot Language
Server's proxy settings. No proxy is configured by default. Keep machine-specific
network settings and credentials out of the shared configuration.
`:checkhealth CopilotChat` and `:Copilot status` help with diagnostics.

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

The usability tests also check Copilot lazy-loading, chat context defaults and
the nvim-cmp/Copilot visibility handoff without authentication or network requests.
The tests use temporary Cargo workspaces without external crate dependencies and
real terminal jobs. Plugin interfaces are stubbed, so neither installed plugins
nor GDB are required. Temporary files and shell processes are cleaned up afterward.
