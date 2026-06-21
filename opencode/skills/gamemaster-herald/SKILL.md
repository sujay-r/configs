---
name: gamemaster-herald-opencode
description: >
  Use this skill at the start of any coding session when the user provides task or quest IDs
  to work from. This skill governs how OpenCode interacts with Gamemaster via Herald MCP —
  fetching delegated work, understanding task context, and reporting progress back through
  task notes. Always consult this skill before making any Herald tool call.
compatibility:
  required_tools:
    - Herald MCP (gamemaster-herald)
---

# Gamemaster Herald — OpenCode Skill

## What is Gamemaster?

Gamemaster is the user's personal task and project management system. It is the collaboration
surface between the user and their AI agents. Think of it as JIRA for this workflow — tasks
and quests are the specs, and notes are the audit trail.

**Your role**: You are a coding agent. Gamemaster is not your concern beyond two things —
reading your delegated work and writing back what you've done.

---

## Delegation Context

Tasks you're handed carry an `opencode` tag in Gamemaster — that's how the user, via Viveka
(the orchestrating agent), marks work as explicitly delegated to you. It's an audit marker
only; you never search for tagged work yourself, you're always given specific task or quest
IDs directly.

You have no conversational context beyond what's in the task. The `description` and `notes`
fields are the entire specification — if it isn't written there, you don't know it. When you
report back, write a dated-entry HTML block (see "Reporting Back" below) so your progress,
decisions, and results are visible to the user and to Viveka on the next turn.

---

## Core Entities (what you need to know)

**Task** — an atomic unit of work. Has a title, description, status (`TODO` | `IN_PROGRESS` | `DONE`),
and notes (HTML). Notes are your primary feedback channel back to the user.

**Quest** — a container grouping related tasks. Fetching a quest gives you all its tasks at once.
Use this when you've been given a quest ID instead of individual task IDs.

---

## Session Start — How to Fetch Your Work

You will always be given specific task or quest IDs by the user. You do not discover your
own work — you fetch only what you've been told to fetch.

**Given a quest ID** → call `get_quest_tool` with `includeTasks: true`. This fetches the quest
and all its tasks in a single call — no separate list-and-filter step needed.

**Given specific task IDs** → call `get_task_tool` once per ID. There is no batch fetch-by-ID
tool, so loop over the IDs you were given.

Do not fetch anything beyond what you've been given. Do not pull all tasks or all quests.

---

## Reading Task Context

Task `description` contains the spec — what needs to be built or fixed.
Task `notes` may contain prior progress, decisions, or blockers from previous sessions.

Always read existing notes before starting work on a task. Do not ignore prior context.

---

## Reporting Back — Notes Rules

`update_task_notes_tool` is your only write operation. Use it to report:
- What you implemented and key decisions made
- Any blockers or open questions for the user
- Anything that deviated from the spec

**Notes are HTML.** Always write valid HTML. Never write markdown or plain text.

**Notes are append-only.** The tool overwrites the full field — but you must never discard
prior content. Always:
1. Fetch current notes via `get_task_tool` (the single-task fetch, not a list call)
2. Append your new dated entry to the existing HTML
3. Write the full reconstructed HTML back

**Dated entry format:**
```html
<p><strong>29 Apr 2026</strong></p>
<ul>
  <li>Implemented X using approach Y.</li>
  <li>Decided against Z because of W — left a TODO comment in the code.</li>
  <li>Open question: should the API return 404 or empty array for missing quest IDs?</li>
</ul>
```

---

## Write Rules

- **Never create tasks or quests.** You read and you report. Nothing else — this holds even
  though `create_task_tool` / `create_quest_tool` now exist live; they're scoped to the
  orchestrator (Viveka), not to you.
- **Never update any field other than `notes`.** Status changes, due dates, token rewards,
  descriptions — all off limits, even though tools like `update_task_due_date_tool` exist.
- **Always fetch before writing notes.** Reconstruct the full HTML before calling
  `update_task_notes_tool`.
- **No confirmation needed for reads.** Fetch freely.
- **No confirmation needed for note updates** — but always append, never overwrite prior content.

---

## What You Cannot Do

- Create or delete tasks or quests
- Mark tasks as complete
- Modify token rewards, stats, due dates, or any other field besides notes
- Fetch data beyond the IDs you were given
- Claim rewards (not applicable to you)
