---
name: gamemaster-herald
description: >
  Use this skill whenever the user asks anything related to Gamemaster — their tasks, quests,
  stats, tokens, rewards, or daily progress. Also use it when the user asks you to create a task or quest,
  update task notes, or check what they're working on today. This skill provides both background
  context on what Gamemaster is and strict usage rules for the Herald MCP tools. Always consult
  this skill before making any Herald tool call, even for simple reads.
compatibility:
  required_tools:
    - herald
---

# Gamemaster – Herald Skill

## What is Gamemaster?

Gamemaster is a personal productivity PWA built around RPG mechanics. The user manages their life through a system of tasks, quests, stats, and token rewards. It is intentionally playful but not over-gamified — the goal is low-friction, meaningful progress tracking.

### Core Entities

**Task** — an atomic action item. Has a title, optional description, status (`TODO` | `IN_PROGRESS` | `DONE`), optional token reward, optional notes (Markdown), tags, and an optional link to a Quest.

**Quest** — a container grouping related tasks. Has a status with three values:
- `active` — the quest is in-progress and visible in the main QuestView.
- `todo` — the quest is backlogged (planned but not yet active). Visible only in the BacklogView, accessible from within the QuestView via "View Backlog".
- `completed` — the quest is finished.

Quests are mutable through `quest_update`: a backlog quest can be activated and an active quest can be completed. Quests do not directly generate rewards. `quests_list` returns a per-quest task count and status rollup; `quest_get(include=["tasks"])` returns summary task rows for one quest.

**Resource** — the user's character state:
- *Tokens* (`Care`, `Grind`) — automated, earned by completing tasks, spent on rewards.
- *Stats* (`Health`, `Mood`, `Focus`, `Energy`) — manually updated by the user to encourage reflection. May have buffs and debuffs attached.
- *Rewards* — claimable benefits purchased with tokens. `state_get(include=["rewards"])` reports costs and affordability.

### Gameplay Loop

1. User completes tasks → earns Care / Grind tokens automatically.
2. User spends tokens to claim rewards.
3. User manually reflects on and adjusts stats.
4. Today's Log resets at midnight.

---

## The Herald Surface — 9 Tools

**Reads (5):** `tasks_list`, `task_get`, `quests_list`, `quest_get`, `state_get`
**Writes (4):** `task_create`, `task_update`, `quest_create`, `quest_update`

There are **no resources and no prompts**. Everything is a tool. All tools return
structured JSON plus a short text line, and every tool carries annotations.

### Two axes of verbosity

- `detail`: `"summary"` (default) or `"full"` — scalar fields only. `full` adds
  description, timestamps, outcomes, or counts. It **never** adds notes.
- `include`: expensive payload blocks. For reads: `["notes"]`; for `quest_get`
  also `["tasks"]` (summary child rows only).

**Notes cost 93% of the payload and never travel unless `include=["notes"]` is
set.** Do not request notes speculatively.

### Reads at a glance

| Tool | Use for | Key arguments |
|---|---|---|
| `tasks_list` | Any task query | `view` (`all|today|overdue`), `status`, `quest_id`, `ids`, `search` (title), `tags` (ALL-of), `due_before`, `due_after`, `completed_since`, `detail`, `include`, `limit`, `offset` |
| `task_get` | One task | `task_id`, `detail`, `include` |
| `quests_list` | Quest overview | `status`, `ids`, `search`, `detail`, `include`, `limit`, `offset` |
| `quest_get` | One quest | `quest_id`, `detail`, `include` (`tasks`, `notes`) |
| `state_get` | Tokens/stats/rewards/capabilities | `include` (`tokens|stats|rewards|capabilities`) |

`tasks_list(ids=[...])` replaces the old batch-by-ID read and cannot be combined
with other filters. `view="today"` is the old today tool (pending, in-progress,
completed today, **and overdue**).

### Writes at a glance

| Tool | Use for |
|---|---|
| `task_create` | New task; always starts `TODO` |
| `task_update` | **Batch** updates: status, due date, tags (replace-all), quest link, title, description, notes (replace), note_append (server-side append) |
| `quest_create` | New quest (defaults `type="side"`, `status="todo"`) |
| `quest_update` | Status (activate/complete), title, description, type, tags, notes, note_append |

All writes return a compact receipt `{id, title, status, changed[]}` — never a
record and never a note body.

### The DONE gate

`task_update(status="DONE")` refuses any task that does not carry the `opencode`
tag. The tag marks work actually delegated to a coding agent; the rule is
Herald's own invariant. Because updates are batched, the gate is
**all-or-nothing**: one offending item rejects the whole call, nothing is
written, and the rejection names the offending task IDs. Close a delegated task
only after the user confirms the work is complete.

### `note_append`

Never read-modify-write notes again. Send only the Markdown body and Herald
prepends `**27 Oct 2026**` and appends it after existing content:

```json
{"id": 42, "note_append": "- **Update:** completed the migration."}
```

`notes` (full replace) and `note_append` are mutually exclusive per item.
Prefer `note_append` unless the user explicitly wants a rewrite.

---

## What You Cannot Do

- Delete any entity — ever.
- Update arbitrary task fields through hidden paths — writes are limited to the
  four tools above and must be previewed.
- Mark a task DONE unless the user explicitly confirms **and** the task carries
  the `opencode` tag. The tool enforces this; a batch containing an untagged
  DONE item is rejected in full.
- Modify token balances, stats, buffs, or debuffs directly.
- Claim rewards.
- Write anything without explicit user confirmation.

---

## Daily Planning Workflow

Use when the user starts a planning session. Read `tasks_list(view="today")`
and `state_get()` first; group by quest using `quests_list` if needed.

### Step 0 — Overdue rescheduling

1. `tasks_list(view="overdue")`.
2. Present them as a table: task, quest, original due date.
3. Ask for each: new due date, `clear`, or `skip`. Tasks not explicitly
   addressed default to today's date.
4. Show one batch preview of the due-date changes, get explicit confirmation,
   then send a **single** `task_update` call with one item per task.

### Step 1 — Draft plan

Propose an execution order across three time blocks:
- **Focus hours:** 6:00 AM – 12:00 PM
- **Post-lunch:** 2:00 PM – 5:00 PM
- **Wind-up:** 7:00 PM – 11:00 PM

**Stat heuristic:** assign sustained-concentration work to Focus hours when
Focus ≥ 70 and Energy ≥ 70. When either is below 65, put routine or
administrative work in that block. Scale thresholds proportionally if stats use
a different range.

Do not include rescheduled tasks that moved to a future date. Do not show
internal reasoning.

### Step 2 — Revision

Apply the user's feedback and present the revised plan. Wait for confirmation.

### Step 3 — Socratic breakdown

Go task by task in planned order, grouped by quest. Ask:

> "Let's break down **[Task Title]** from **[Quest Title]**. Walk me through the steps you'd take — and mention any tools or references you'll need for each step."

**Never suggest steps.** The user defines the approach. Ask clarifying
questions when vague. If the user skips, acknowledge and move on. Complete every
task before writing.

### Step 4 — Batch write-back

Build one planning note per task and show a single bulk preview. On confirmation,
send **one** `task_update` call with an item per task using `note_append`:

```markdown
**Planning — 27 Oct 2026**

**Block:** Focus | **Order:** 1 of 4

- **Step 1:** [user's step] — *[tools/references]*
- **Step 2:** [user's step] — *[tools/references]*

**Execution notes:** [freeform, omit if none]
```

If a task's breakdown was skipped, keep only the block/order line.

**Hard rules:** never suggest steps during breakdown; never assign token rewards
unless the user specifies them; never write without confirmation; never skip a
step; write the whole plan in one batch, not task by task.

---

## End-of-Day Wrap-Up Workflow

Use when the user reconciles the day. Role: gather and record, do not evaluate.

### Step 0 — Overdue rescheduling

Same as planning: `tasks_list(view="overdue")`, one preview, one `task_update`
batch of due-date changes.

### Step 1 — Snapshot

`tasks_list(view="today")`. Show today's tasks grouped by quest with status and
due date. Wait for the user to begin.

### Step 2 — Status updates

For each non-DONE task ask: "Any updates on **[task title]**?" Record responses
faithfully; do not paraphrase. Accumulate `note_append` bodies in memory — do not
write yet.

### Step 3 — Reschedule

For each non-DONE task ask when it is being picked up. Convert relative dates
("tomorrow", "next Monday") to `YYYY-MM-DD`; `clear`/`no date` means `due_date:
null`. Never suggest dates.

### Step 4 — Single preview

Show one consolidated preview grouped by task:

```
[Task Title] (id: N)
  • Notes: append dated entry — "[summary]"
  • Due date: [new date / cleared]
```

Omit tasks with no changes. Ask once: "Shall I go ahead and write these?"

### Step 5 — Execute

On confirmation, send **one** `task_update` call. Each item carries the
`note_append` body and/or `due_date`; tasks with no change are omitted.

### Step 6 — Close out

For tasks the user confirms complete, verify each carries the `opencode` tag
(`tasks_list(ids=[...])`). If any does not, tell the user the gate blocks it and
offer to attach the tag first. Then send a batch of `status="DONE"` items. If the
batch contains one untagged task the whole call is rejected, so confirm tags
before writing.

Remind the user that rewards are claimed by them, never by you.

**Hard rules:** do not evaluate the day; do not infer note content or due dates;
single confirmation for the whole batch; scope is today + overdue only; never
claim rewards, delete entities, or modify token balances.

---

## References

Load these only when the relevant action arises:

- `references/tools.md` — the 9 tools, output shapes, `detail`/`include`, receipts, and awareness guidance. Load when the user asks about tasks, quests, stats, or daily progress.
- `references/write-rules.md` — rules for safe write operations. Load before calling `task_create`, `task_update`, `quest_create`, or `quest_update`.
- `references/notes-format.md` — Markdown format rules and the `note_append` pattern. Load before writing task notes.
- `references/opencode-delegation.md` — how to write tasks/quests for OpenCode delegation. Load when creating tasks intended for a coding agent.
