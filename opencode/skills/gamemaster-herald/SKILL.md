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

**Your role**: You are a coding agent. Gamemaster is not your concern beyond three things —
reading your delegated work, producing a technical plan, and writing back what you've done.

---

## Delegation Context

Tasks you're handed carry an `opencode` tag in Gamemaster — that's how the user, via Viveka
(the orchestrating agent), marks work as explicitly delegated to you. It's an audit marker
only; you never search for tagged work yourself, you're always given specific task or quest
IDs directly.

You have no conversational context beyond what's in the task. The `description` and `notes`
fields are the entire specification — if it isn't written there, you don't know it.

---

## The Delegation Pipeline

Your work follows one of two paths:

### Path A: PLAN (first delegation call)

When delegated with a task, you are in the **planning phase**:

1. **Fetch the task** via `get_task_tool` (or `get_quest_tool` if given a quest ID with `includeTasks: true`).
2. **Read the Scope Document** — the task `notes` field contains a 7-section Scope Document
   (see "Scope Document Format" below). This is your specification.
3. **Produce a technical plan** covering:
   - Architecture and approach
   - Data model changes (if any)
   - Implementation steps, ordered by user story priority (P1 → P2 → P3)
   - Dependencies and assumptions
   - Research decisions with rationale
4. **Save the plan** to `specs/<task-title-slug>/plan.md` in the repository.
   The `<task-title-slug>` is the task title lowercased with spaces replaced by hyphens
   (e.g., "Fix TUI tool call display" → `specs/fix-tui-tool-call-display/plan.md`).
5. **Return the plan** in the `delegate_to_agent` response. Do NOT update task notes at this stage.

### Path B: IMPLEMENT (second delegation call, after plan is approved)

When given the same task ID again after your plan has been approved:

1. **Re-fetch the task** and your previously saved plan from `specs/<task-title-slug>/plan.md`.
2. **Implement** according to the approved plan.
3. **Evaluate** your implementation against Section 7 (Success Criteria) from the Scope Document.
4. **Report** — write a structured dated entry into task notes (see "Reporting Back" below).

---

## Scope Document Format

The task `notes` field will contain a Scope Document with this structure:

```
# Scope Document

## 1. Problem Statement
- Reframed articulation of the problem
- What pain exists and for whom
- Why this problem matters *now*

### 1.1 User Stories
- **US1** - [Brief Title] (Priority: P1)
  - Plain-language description of who, what, why
  - Why this priority
  - Independent Test: How to verify this story works in isolation
- **US2** - [Brief Title] (Priority: P2)
  - ...
- **US3** - [Brief Title] (Priority: P3)
  - ...

## 2. In-Scope
- Explicit list of what this effort will cover
- Conceptual capabilities only (no how)

## 3. Out-of-Scope
- Explicit exclusions
- Things intentionally deferred or rejected

## 4. Assumptions
- Assumptions made due to missing information
- Clearly marked as assumptions (not facts)

## 5. Constraints
- Time, organizational, process, or context constraints
- No technical constraints yet

## 6. Open Questions
- Known unknowns
- Each question should block or shape future decisions

## 7. Success Criteria
- What "good" looks like
- How a reader would know the problem is well-scoped
```

- **User Stories** are priority-ordered (P1 = highest). Plan and implement in this order.
- **Independent Test** per story tells you how to verify each story in isolation.
- **Success Criteria** (Section 7) are your evaluation checklist after implementation.
- **Out-of-Scope** (Section 3) are hard boundaries — do not exceed them even if you see a "better" way.

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

**Determine which path you're on**: Check if `specs/<task-title-slug>/plan.md` exists.
If it doesn't → you're in Path A (PLAN). If it does → you're in Path B (IMPLEMENT).

Do not fetch anything beyond what you've been given. Do not pull all tasks or all quests.

---

## Reading Task Context

Task `description` contains a one-line brief of what needs to be built.

Task `notes` contains the full Scope Document (7 sections) plus any prior progress,
decisions, or blockers from previous sessions.

Always read existing notes before starting work. Do not ignore prior context.

---

## Reporting Back — Notes Rules

`update_task_notes_tool` is your only write operation. Only use it during Path B (IMPLEMENT).
Do not update notes during Path A (PLAN) — the plan is returned in the delegation response
and saved to the repo.

When reporting:

- What you implemented and key decisions made
- Test results against Section 7 Success Criteria (pass/fail per criterion)
- Any deviations from the plan and why
- Known issues or follow-up items

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
  <li><strong>Plan:</strong> implemented X using approach Y — saved to specs/x/plan.md.</li>
  <li><strong>Success Criteria:</strong>
    <ul>
      <li>SC-001: PASS — users complete task in under 2 min.</li>
      <li>SC-002: PASS — handles 1000 concurrent users.</li>
    </ul>
  </li>
  <li>Decided against Z because of W — left a TODO comment in the code.</li>
  <li>Open question: should the API return 404 or empty array for missing quest IDs?</li>
</ul>
```

---

## Write Rules

- **Never create tasks or quests.** You read and you report. Nothing else — this holds even
  though `create_task_tool` / `create_quest_tool` exist; they're scoped to the
  orchestrator (Viveka), not to you.
- **Never update any field other than `notes`.** Status changes, due dates, token rewards,
  descriptions — all off limits.
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

