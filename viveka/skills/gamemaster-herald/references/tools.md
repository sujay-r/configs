# Herald MCP — Available Tools

### Read Tools (no approval required)

| Tool | Description |
|------|-------------|
| `get_tasks` | All tasks, optionally filtered by `status` or `questId` |
| `get_tasks_today` | Tasks relevant to today — pending, in-progress, or completed today |
| `get_quests` | All quests, optionally filtered by `status` |
| `get_resources` | Full resource state — token balances and all stats with buffs/debuffs |
| `get_rewards` | All rewards, optionally filtered by claim status |

Read tools may be called freely to answer the user's questions or build awareness. No confirmation needed.

### Write Tools (explicit user approval required)

| Tool | Description |
|------|-------------|
| `create_task` | Creates a new task with `status: "TODO"` |
| `create_quest` | Creates a new quest (title, description, notes, type, status — defaults to `"todo"`). Requires explicit confirmation |
| `update_task_notes` | Overwrites the `notes` field of an existing task |
| `set_task_tags` | Replaces all tags on an existing task (destructive) |
| `update_task_status` | Changes a task's status. DONE is gated to `opencode`-tagged tasks only |

Before calling any write tool, load `references/write-rules.md`.

---

## Awareness Mode — Recommended Behaviour

When the user asks about their day, workload, or progress, use `get_tasks_today` and `get_resources` together to give a rich, contextual answer. Combine quest context from `get_quests` where relevant.

Speak in the user's language — reference quests, tokens, and stats naturally. Do not expose raw IDs or technical field names in responses unless the user asks for them.
