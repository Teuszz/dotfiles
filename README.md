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

The tests use temporary Cargo workspaces without external crate dependencies and
real terminal jobs. Plugin interfaces are stubbed, so neither installed plugins
nor GDB are required. Temporary files and shell processes are cleaned up afterward.
