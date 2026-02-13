# External Tools

Three optional tools that enhance the persistent agent system.

## 1. TDD Guard — Mechanical TDD Enforcement

**What it does:** Claude Code hook that intercepts `Write|Edit|MultiEdit` tool calls and blocks implementation code unless failing tests exist. Uses a test reporter to track test state and a validator LLM call to judge whether edits are test-first.

**Why it matters:** Prompt-based TDD rules ("write tests first") can be forgotten or rationalized away. TDD Guard makes them mechanically unbypassable. The validator is a full LLM call, so it can reason about subtle violations like copy-paste tests or reimplemented logic.

**How it integrates:**
- Global hooks in `~/.claude/settings.json` (PreToolUse, UserPromptSubmit, SessionStart)
- Custom instructions auto-created per-project at `.claude/tdd-guard/data/instructions.md` (from template)
- Subagents inherit global hooks — TDD is enforced at the tool level, not just the prompt

**Per-project setup:** Each project needs a test reporter. For Vitest:
```bash
pnpm add -D tdd-guard-vitest
```

Then in `vitest.config.ts`:
```typescript
import { VitestReporter } from 'tdd-guard-vitest'

export default defineConfig({
  test: {
    reporters: ['default', new VitestReporter()],
  },
})
```

**Install:**
```bash
npm install -g tdd-guard
```

**Caveats:**
- Requires Node.js 22+
- Each code edit triggers a validator LLM call (subscription-based, no extra cost, but rate-limited)
- Session toggle available (`/tdd on`, `/tdd off`) for pure config work

---

## 2. recall — Session Search

**What it does:** Rust binary that indexes Claude Code session files. Full-text search across all past conversations. Interactive TUI for browsing and resuming sessions.

**Why it matters:** Full-text search across all past Claude Code sessions — not just ones you logged manually.

**How it integrates:**
- Standalone CLI, no configuration needed
- Referenced in CLAUDE.md so the agent knows to use `recall search "query"` for finding past conversations
- Complements curated session logs — recall is "grep for conversations," session JSONL is "what mattered"

**Install:**
```bash
# macOS
brew install zippoxer/tap/recall

# Linux / from source
cargo install --git https://github.com/zippoxer/recall
```

---

## 3. Vestige — Cognitive Memory MCP

**What it does:** MCP server implementing a memory system based on cognitive science. Features:
- Dual strength model (storage vs retrieval, like human long-term memory)
- FSRS-6 spaced repetition — unused memories naturally decay
- Spreading activation — recalling one memory activates related ones
- Duplicate detection via `smart_ingest`
- Semantic search with local embeddings (~130MB model, no API needed)

**Why it matters:** Gives the agent memory that persists across sessions without manual curation. Bug fixes, decisions, preferences, and patterns are captured automatically during sessions and retrieved on demand later.

**How it integrates:**
- Registered as a global MCP server: `claude mcp add vestige vestige-mcp -s user`
- CLAUDE.md instructs the agent on when to save and search
- Minimal cold-start footprint: only `intention(action="check")` at startup
- Flat files (MEMORY.md, TOOLS.md) remain source of truth for identity
- Vestige is working memory and long-tail knowledge

**Key tools:**
| Tool | Use |
|------|-----|
| `smart_ingest` | Save a memory (auto-deduplicates) |
| `search` | Find relevant memories |
| `intention` | Set/check reminders and triggers |
| `promote_memory` | Strengthen a useful memory |
| `demote_memory` | Weaken wrong/outdated memory |
| `codebase` | Remember decisions and patterns |

**Install:**
```bash
# Download binary
curl -L https://github.com/samvallad33/vestige/releases/latest/download/vestige-mcp-x86_64-unknown-linux-gnu.tar.gz | tar -xz
sudo mv vestige-mcp vestige vestige-restore /usr/local/bin/

# Register with Claude Code
claude mcp add vestige vestige-mcp -s user

# Verify
vestige health
```

**Caveats:**
- First run downloads ~130MB embedding model (cached after that)
- Memory decay means old unused memories fade — use `promote_memory` for keepers
- No cloud sync — single machine only
- Back up `~/.local/share/vestige/core/vestige.db` periodically
