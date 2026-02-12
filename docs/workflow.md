# Recommended Workflow

## Side-by-Side Review with Neovim

Claude Code runs in one tmux pane. Neovim runs in another with `autoread` enabled.
As Claude writes files, neovim picks up changes live — you review in real time.

### Neovim Config

Add to your `init.lua`:

```lua
-- Auto-reload files changed outside neovim
vim.o.autoread = true
-- Check for changes when you focus the window or move the cursor
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})
```

### tmux Layout

Three windows in your tmux session:
1. `claude` — Claude Code
2. `edit` — neovim for live review
3. `shell` — general terminal

Or use a vertical split for side-by-side:

```bash
tmux split-window -h "nvim ."
```

### Using /review

Run `/review` in Claude Code to automatically open a neovim split.
Switch between panes with `ctrl+b →` and `ctrl+b ←`.

### Why This Works

You see changes as they happen, and you can edit the same files simultaneously
to course-correct. Neovim gives you full vim navigation, search, and LSP —
more powerful than any built-in diff viewer.
