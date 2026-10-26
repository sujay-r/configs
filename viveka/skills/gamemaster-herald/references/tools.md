# Herald MCP — Available Tools

Exactly **9 tools, 0 resources, 0 prompts**. Every read is a tool because a
model cannot request MCP resources; the host decides those.

### Read Tools (no approval required)

| Tool | Description | Key arguments |
|------|-------------|----------------|
| `tasks_list` | Tasks by view, status, quest, IDs, title search, tags, or dates | `view`, `status`, `quest_id`, `ids`, `search`, `tags`, `due_before`, `due_after`, `completed_since`, `detail`, `include`, `limit`, `offset` |
| `task_get` | One task | `task_id`, `detail`, `include` |
| `quests_list` | Quests with task counts and status rollups | `status`, `ids`, `search`, `detail`, `include`, `limit`, `offset` |
| `quest_get` | One quest, optionally with summary task rows or notes | `quest_id`, `detail`, `include` |
| `state_get` | Tokens, stats, rewards, capabilities | `include` |

Read tools may be called freely to answer the user's questions or build
awareness. No confirmation needed.

### Write Tools (explicit user approval required)

| Tool | Description |
|------|-------------|
| `task_create` | Creates a task with `status: "TODO"` |
| `task_update` | **Batch** update: status, due date, tags (replace-all), quest link, title, description, notes, note_append |
| `quest_create` | Creates a quest (title, type, status, description, notes, tags — defaults `type="side"`, `status="todo"`) |
| `quest_update` | Status (activate/complete), title, description, type, tags, notes, note_append |

Before calling any write tool, load `references/write-rules.md`.

---

## Two Axes of Verbosity

- `detail`: `"summary"` (default) or `"full"`. Scalar fields only. `full` adds
  descriptions, timestamps, outcomes, or counts. It **never** adds notes.
- `include`: expensive blocks. `["notes"]` on task/quest reads; `["tasks"]` on
  `quest_get` only. `state_get` takes `tokens|stats|rewards|capabilities`.

Notes never travel unless `include=["notes"]` names them. Notes arrive as
**Markdown**; storage is HTML.

## Page Envelope

List tools return:

```json
{"items": [...], "truncated": true, "total": 272, "offset": 0, "limit": 50}
```

- `limit` 1–200, default 50. `offset` default 0.
- Check `truncated` for "are there more rows", not `len(items)`.
- Reading past the end returns an empty page with the correct `total`.

## Summary Shapes

| Entity | Summary keys |
|---|---|
| Task | id, title, status, questId, dueDate, completedToday, isOverdue, tags, reward |
| Quest | id, title, type, status, tags, taskCount, counts{todo,inProgress,done,overdue} |
| State | tokens[{token_type,quantity}], stats[{name,value,effects}], rewards[{id,title,status,costs,affordable}], capabilities |

- Task `full` adds `description, createdAt, completedAt, outcomes[]`.
- Quest `full` adds `description, createdAt, updatedAt`.
- A quest's tasks are never inlined by `quests_list`. Use
  `quest_get(include=["tasks"])` for **summary** rows or
  `tasks_list(quest_id=N)` for full task filtering.

## `tasks_list` Views

- `view="all"` (default) — every task.
- `view="today"` — pending, in-progress, completed today, **and overdue**.
- `view="overdue"` — past due and not done.
- `ids=[...]` is a batch read and is mutually exclusive with every other filter.
- `search` is title-only; `tags` uses ALL-of semantics; `due_before` and
  `due_after` are inclusive dates.

## Write Receipts

Every write returns `{id, title, status, changed[]}`. `task_update` returns
`{receipts: [...], count}`. `changed[]` lists the snake_case fields actually
written. Notes and descriptions never come back in a receipt.

Receipts confirm a write; they are not reads. To show resulting content, fetch
it back with `include=["notes"]` or `detail="full"`.

---

## Awareness Mode — Recommended Behaviour

When the user asks about their day, workload, or progress:

1. `tasks_list(view="today")` for what needs attention.
2. `state_get()` for token and stat context.
3. `quests_list(status="active")` for the quest overview; the `counts` rollup
   tells you which quests need a follow-up `tasks_list(quest_id=N)` — you no
   longer need one call per quest.

Ask for `include=["notes"]` only for the specific task or quest whose notes you
need. Never request a full quest with notes just to see its tasks.

Speak in the user's language — reference quests, tokens, and stats naturally.
Do not expose raw IDs or technical field names unless the user asks.
