# Persistent Claude Code Agent

A portable system for giving Claude Code persistent memory, session logging,
and battle-tested subagent orchestration rules.

## What You Get

- **Persistent memory** — Claude knows who you are across sessions
- **Session logging** — what happened, what was decided, what's unfinished
- **Pattern accumulation** — lessons learned that compound over time
- **Orchestration rules** — hard-won rules for effective subagent delegation
- **Task tracking** — optional [beads](https://github.com/codegangsta/beads) integration for repo-level work

## Install

```bash
git clone git@github.com:Aklaran/claude-persistent-agent.git
cd claude-persistent-agent
./install.sh
```

Then edit:
- `~/.claude/memory/MEMORY.md` — tell Claude who you are
- `~/.claude/memory/TOOLS.md` — document your infrastructure

## Commands

| Command | What it does |
|---------|-------------|
| `/reflect` | Log a pattern, reflection, or idea |
| `/log-session` | Summarize and log current session |
| `/beads` | Show ready work from bead databases |
| `/status` | Quick orientation (tasks + today's log) |
| `/review` | Open neovim in tmux split for live review |

## How It Works

See [docs/memory-system.md](docs/memory-system.md) for the memory system
and [docs/orchestration.md](docs/orchestration.md) for the delegation rules.

## Recommended Setup

For the best experience, set up the side-by-side neovim workflow described in
[docs/workflow.md](docs/workflow.md).

Add to your `init.lua`:

```lua
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})
```

## Customizing

The system is intentionally simple. Everything is markdown files and JSONL.
Fork it, change the CLAUDE.md rules, add your own commands.
