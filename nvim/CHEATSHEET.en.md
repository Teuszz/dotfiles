# Neovim Cheatsheet

For this repository's Neovim configuration (Neovim 0.12+).

[Deutsche Version](CHEATSHEET.de.md)

**Notation:** `Space ff` means press Space, then `f`, then `f`.
`Ctrl+w h` means press `Ctrl+w`, then `h`; press `Alt+t` simultaneously.
Confirm commands starting with `:` by pressing `Enter`.
Unless stated otherwise, shortcuts apply in **Normal mode**.

## 1. Neovim Basics

### Modes and Files

| Key / Command | Action |
| --- | --- |
| `Esc` | Return to Normal mode |
| `i` / `a` | Insert before / after the cursor |
| `I` / `A` | Insert at the first non-blank character / end of the line |
| `o` / `O` | Open a new line below / above and start inserting |
| `v` / `V` / `Ctrl+v` | Select characters / entire lines / a rectangular block |
| `:` | Open the command line |
| `:e path/file` | Open a file |
| `:w` / `:wa` | Save the current / all modified files |
| `:q` / `:wq` | Close the window / save and close the window |
| `:qa` / `:wqa` | Quit Neovim / save everything and quit |
| `:q!` / `:qa!` | Close the window / quit Neovim without saving; changes are lost |

### Movement

| Key | Action |
| --- | --- |
| `h` / `j` / `k` / `l` | Left / down / up / right |
| `w` / `b` / `e` | Next word start / previous word start / word end |
| `0` / `^` / `$` | Line start / first non-blank character / line end |
| `gg` / `G` / `42G` | File start / file end / line 42 |
| `5j` / `5k` | Five lines down / up; counts can be combined with motions |
| `Ctrl+d` / `Ctrl+u` | Scroll half a screen down / up |
| `zz` | Center the cursor line in the window |
| `fX` / `tX` | Jump to the next character `X` / just before it |
| `;` / `,` | Repeat the last `f`/`t` search / repeat in the opposite direction |
| `%` | Jump to the matching bracket |
| `Ctrl+o` / `Ctrl+i` | Go back / forward in the jump list |

### Editing, Copying, and Indentation

| Key | Action |
| --- | --- |
| `u` / `Ctrl+r` | Undo / redo |
| `.` | Repeat the last text change |
| `x` / `dd` / `D` | Delete a character / line / to the end of the line |
| `yy` / `p` / `P` | Copy a line / paste after or below / before or above the cursor |
| `dw` / `cw` | Delete to the next word start / change a word and start inserting |
| `ciw` / `diw` / `yiw` | Change / delete / copy the word under the cursor |
| `ci"` / `ci(` | Change the contents inside quotes / parentheses |
| `d` / `y` / `c` in Visual mode | Delete / copy / change the selection |
| `>>` / `<<` | Indent / unindent the line |
| `>` / `<` in Visual mode | Indent / unindent the selection |
| `==` / `gg=G` | Reindent the line / entire file using the indentation rules |
| `J` | Join the current and next line |
| `"+y` in Visual mode / `"+p` | Copy to / paste from the system clipboard, if a clipboard provider is available |

**Rule of thumb:** Operator + motion or text object, e.g. `d$` (delete to the
end of the line), `yap` (copy a paragraph with adjacent blank lines), `3dd`
(delete three lines). Deleting normally also stores the text in a register.
`gg=G` adjusts indentation; it is not full LSP formatting.

### Search and Replace

| Key / Command | Action |
| --- | --- |
| `/text` / `?text` | Search forward / backward in the current file |
| `n` / `N` | Next / previous match relative to the search direction |
| `*` / `#` | Search for the word under the cursor forward / backward |
| `:noh` | Hide search highlighting until the next search |
| `:%s/old/new/gc` | Replace throughout the file; confirm each match |
| `:'<,'>s/old/new/gc` | Replace only in selected lines; pressing `:` after a visual selection inserts the range automatically |

Search and substitution patterns are regular expressions, not plain text.

### Windows, Buffers, and Help

A **buffer** holds an open file; a **window** displays a buffer.
A Neovim **tab page** contains a window layout, not just a file.

| Key / Command | Action |
| --- | --- |
| `:split` / `:vsplit` | Split the window horizontally / vertically |
| `Ctrl+w h/j/k/l` | Switch to the window on the left / below / above / right |
| `Ctrl+w w` | Switch to the next window |
| `Ctrl+w =` | Equalize window sizes |
| `Ctrl+w c` / `Ctrl+w o` | Close the current window / all other windows |
| `:ls` | List buffers with their internal IDs |
| `:bn` / `:bp` / `:b 3` | Next / previous buffer / buffer with ID 3 |
| `:bd` | Close the current buffer; unsaved changes prevent this |
| `:tabnew` / `gt` / `gT` | New tab page / next / previous tab page |
| `:pwd` / `:cd path` | Show / change the working directory |
| `:help topic` | Open help, e.g. `:help motion` or `:help registers` |

## 2. Your Plugins and Configuration

### Startup and Orientation

- `nvim`: Alpha dashboard with recently opened files; use the shortcuts shown
  on the dashboard.
- `nvim file.rs`: Edit the file directly without focusing the explorer.
- `nvim path/to/project`: Open Neo-tree for that directory. This does **not**
  change the working directory. For project-wide searches, it is best to
  change into the project in your shell before launching Neovim.
- Leader is **Space**, Localleader is `\`. Relative line numbers help with
  jumps such as `7j`; the cursor line shows its absolute number.
- Tab input becomes spaces; indentation width is two.
  Treesitter provides syntax highlighting and indentation for configured languages.

### Finding Files and Switching Buffers

| Key / Command | Action |
| --- | --- |
| `Space ff` | Telescope: find files in the current working directory |
| `Space fg` | Telescope: search file contents; requires `ripgrep` (`rg`) |
| `Space n` | Open/focus Neo-tree on the left and reveal the current file; **not a toggle** |
| `Space 1` ... `Space 9` | Open a buffer by its position in the bufferline |
| `Space $` | Open the last buffer in the bufferline |
| `Space bd` | Close the current file buffer without changing the window layout |
| `:Neotree close` | Close the explorer |
| `:Telescope buffers` | Select an open buffer using Telescope |

Bufferline numbers are **positions**, not the internal IDs shown by `:ls`.
The bar shows buffers, not tab pages.

`Space bd` displays the next file buffer, or the previous one, in the same
window. Closing the last file leaves an empty editor buffer.
Unsaved changes prevent closing: use `:w` first.
The bufferline close button and right-click use the same behavior.
The standard `:bd` remains unchanged and can close editor windows.

**Telescope defaults:** Type your search, select with `Ctrl+n` / `Ctrl+p`,
and open with `Enter`. `Ctrl+x` / `Ctrl+v` / `Ctrl+t` open in a horizontal
split / vertical split / tab page. `Esc` leaves Insert mode; another `Esc`
closes the picker.

**Neo-tree defaults inside the explorer:** Navigate with `j` / `k`; `Enter`
opens files or toggles folders. `a` creates a file (use a trailing `/` in the
name for a folder), `r` renames, `d` deletes with confirmation, and `?` shows
the available shortcuts.

### Language Features and Diagnostics

Configured language servers: **Lua**, **C/C++**, and **Rust**. Custom LSP
shortcuts apply only when a server is attached to the current buffer.

| Key / Command | Action |
| --- | --- |
| `K` | Show documentation for the symbol |
| `gd` / `gD` | Jump to the definition / declaration |
| `gi` | Jump to the implementation |
| `Space ca` | Select a code action; also works for visually selected code |
| `Space cf` | Format the entire buffer with an LSP formatter |
| `grn` / `grr` | Neovim LSP defaults: rename a symbol / list references |
| `[d` / `]d` | Neovim defaults: previous / next diagnostic |
| `Ctrl+w d` | Neovim default: show diagnostics under the cursor |
| `:Mason` | Manage installed language servers and tools |
| `:checkhealth vim.lsp` | Check the LSP installation |

**No format-on-save:** `:w` does not format. If multiple formatters are
available, `Space cf` offers a selection; without a suitable formatter,
it shows a warning. Rust formatting generally requires `rustfmt`.

### Completion and Snippets

These shortcuts apply in **Insert mode**; snippet jumps also work in Select
mode. Suggestions come from LSP, LuaSnip, or words in the current buffer.

| Key | Action |
| --- | --- |
| `Ctrl+Space` | Request completion |
| `Ctrl+n` / `Ctrl+p` | Select the next / previous suggestion |
| `Enter` | Accept the selected suggestion; if none is selected, accept the first |
| `Ctrl+e` | Abort the completion menu |
| `Ctrl+b` / `Ctrl+f` | Scroll suggestion documentation up / down |
| `Ctrl+l` / `Ctrl+h` | Jump to the next / previous snippet placeholder |

Outside an active snippet, `Ctrl+l` / `Ctrl+h` keep their normal behavior.
`Tab` is neither a custom snippet-jump shortcut nor a Copilot acceptance key
in this configuration.

### GitHub Copilot

Copilot is active only if the local, Git-ignored `copilot-local.lua` in the
configuration directory contains `return "community"` or `return "official"`.
**Without a selection, Copilot is disabled.**
See the [README](../README.md#github-copilot) for setup and authentication.

**Inline suggestions, both providers, in Insert mode:**

| Key / Command | Action |
| --- | --- |
| `Alt+l` | Accept the gray inline suggestion |
| `Alt+]` / `Alt+[` | Show the next / previous inline suggestion |
| `Ctrl+]` | Dismiss the inline suggestion |
| `:Copilot status` | Check status |
| `:Copilot disable` / `:Copilot enable` | Disable / enable inline Copilot |

Inline suggestions are hidden while the completion menu is open.
**`Alt+l` accepts Copilot; `Ctrl+l` jumps within a snippet.**
Automatic suggestions send code context while you type. Filetype filters
do not protect confidential content.

**Chat, `community` only:**

| Key / Command | Action |
| --- | --- |
| `Space ac` | Open/close chat; also works from Visual mode |
| `Space ap` / `Space am` | Select a prompt / available model |
| `Ctrl+s` in chat Insert mode / `Enter` in chat Normal mode | Submit a question |
| `Ctrl+y` in chat | Apply the suggested diff; review it first |
| `:CopilotChatStop` | Stop the current response |
| `:CopilotChatReset` | Reset chat history; does not sign out |

The configured response language is **German**, even when using this English
cheatsheet. Default code context is the **last visual selection** in the source
buffer, not automatically the entire file. Check the selection before submitting;
explicitly add context with `#buffer` / `#file` (`Tab` provides completion).
Opening chat alone does not submit a question.
`:Copilot disable` disables inline suggestions, **not** chat.

### Debugging with nvim-dap

| Key / Command | Action |
| --- | --- |
| `Space b` | Set/remove a breakpoint on the current line |
| `F5` | Select and start a debug profile / continue execution |
| `F10` | Step over a function call |
| `F11` | Step into a function call |
| `F12` | Step out of the current function |
| `:lua require("dap").terminate()` | End the debug session |
| `:checkhealth dap` | Check debugger prerequisites |

Requires **GDB 14+ with Python/DAP support** on `PATH`; Mason does not install
GDB in this configuration. The debug UI opens and closes with the session.

- **Rust:** `Debug Cargo Project` builds executables; `Debug Cargo Test` builds
  test executables and starts the selected one under GDB. Cargo must be
  installed. Multiple targets trigger a selection prompt.
- **Rust/C/C++:** Profiles for custom binaries, process attach, and `gdbserver`
  on `localhost:1234`; build custom binaries with debug symbols.
- Cargo program arguments and `KEY=value` environment overrides are entered
  separated by spaces; shell quoting and spaces within individual values are
  not supported.

### Integrated Terminal

| Key / Command | Action |
| --- | --- |
| `Alt+t` in Normal or Terminal mode | Show/hide the terminal at the bottom (15 lines) |
| `Esc` in the terminal | Enter Terminal-Normal mode; the shell keeps running |
| `i` in Terminal-Normal mode | Resume sending input to the shell |
| `Ctrl+w k` after `Esc` | Switch to the editor window above |
| `:bdelete!` in Terminal-Normal mode | Discard the terminal buffer; the next `Alt+t` starts a new shell |

Hiding preserves the shell process, working directory, and output. `Esc` is
not forwarded to terminal applications. `:bdelete!` can terminate a running
terminal job.

### Managing Plugins and Troubleshooting

| Command | Action |
| --- | --- |
| `:Lazy` | Open plugin management |
| `:Lazy restore` | Restore plugin revisions from the lockfile |
| `:Lazy update` | Update plugins; modifies the lockfile |
| `:Lazy profile` | Inspect plugin load times |
| `:TSUpdate` | Update Treesitter parsers |
| `:checkhealth` | Check installation and external prerequisites |
| `:messages` | Review messages and errors |

Telescope is pinned to tag `0.1.8`: `:Lazy update` does not override this
version constraint. Restart Neovim after plugin updates.
