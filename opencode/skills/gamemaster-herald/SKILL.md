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

Gamemaster is the user's personal task and project management system. It is the collaboration surface between the user and their AI agents. Think of it as JIRA for this workflow — tasks and quests are the specs, and notes are the audit trail.

**Your role:** You are a coding agent. Gamemaster is not your concern beyond three things — reading your delegated work, producing a technical plan, and writing back what you've done.

---

## GATE 0 — Resolve the Repository Path (do this before anything else)

You (OpenCode) are started from a parent `Code` directory that contains **multiple repositories**. Your working directory is never assumed to be the target repo. Every delegation call from Viveka MUST include an explicit absolute repository path in the delegation prompt text, formatted as:

```text
Repository: /absolute/path/to/repo
```

**Before fetching any task, doing any planning, or touching the filesystem:**

1. Check the delegation prompt for a `Repository:` line.
2. If present → store this as `REPO_PATH` for the remainder of the session. All `specs/` paths below are relative to `REPO_PATH`, never to your invocation cwd.
3. If absent or ambiguous → **do not guess. Do not fall back to cwd.** Return immediately:

```text
STATUS: BLOCKED

Issue: No repository path provided in delegation prompt.
Question: Which repository should this task target? (expects an absolute path)
```

This gate applies on **every** delegation call for a given task — planning and implementation both — since the repo path is re-injected each time rather than stored anywhere persistent.

---

## Delegation Context

Tasks you're handed carry an `opencode` tag in Gamemaster — an audit marker only, set by Viveka. You never search for tagged work yourself; you are always given specific task or quest IDs directly, alongside the `Repository:` path from Gate 0.

You have no conversational context beyond what's in the task. The `description` and `notes` fields are the entire specification — if it isn't written there, you don't know it.

---

## The Delegation Pipeline

Your work follows one of two paths. Determine which one you're on using `REPO_PATH` (resolved in Gate 0) — see "Determine Your Path" below.

### Path A: PLAN (first delegation call)

1. **Fetch the task** via `get_task_tool` (or `get_quest_tool` with `includeTasks: true` if given a quest ID).
2. **Read the Scope Document** in the task's `notes` field (7-section format, see below) — this is your specification.
3. **Produce a technical plan** covering:
   - Architecture and approach
   - Data model changes (if any)
   - Implementation steps, ordered by user story priority (P1 → P2 → P3)
   - Dependencies and assumptions
   - Research decisions with rationale
4. **Save the plan to the repo, not your workspace:**
   ```text
   <REPO_PATH>/specs/<task-title-slug>/plan.md
   ```
   Create the directory if it doesn't exist. `<task-title-slug>` = task title, lowercased, spaces → hyphens (e.g., "Fix TUI tool call display" → `fix-tui-tool-call-display`).
5. **Return the plan** via the Response Protocol below. Do **not** update task notes at this stage.

### Path B: IMPLEMENT (second delegation call, after plan approval)

1. **Re-fetch the task** and your previously saved plan from `<REPO_PATH>/specs/<task-title-slug>/plan.md`.
2. **Implement** according to the approved plan.
3. **Evaluate** against Section 7 (Success Criteria) of the Scope Document.
4. **Report** — append a dated entry to task notes (see "Reporting Back" below).

### Determine Your Path

Check whether `<REPO_PATH>/specs/<task-title-slug>/plan.md` exists:

| Plan file exists at REPO_PATH? | You are on |
|---|---|
| No | Path A (PLAN) |
| Yes | Path B (IMPLEMENT) |

If a `specs/<task-title-slug>/` directory exists somewhere else (e.g., your invocation cwd, from before this gate existed) — ignore it. `REPO_PATH` is always the source of truth.

---

## Response Protocol

Your response MUST begin with one of these structured status headers as its first line. Any response without one is treated as an error by the orchestrator (Viveka).

**Plan Ready:**
```text
STATUS: PLAN_READY

[Full technical plan — see Technical Plan Format below]

Saved to <REPO_PATH>/specs/<task-title-slug>/plan.md
```

**Blocked** (missing repo path, missing info, ambiguous scope, technical constraint):
```text
STATUS: BLOCKED

Issue: [what went wrong]
Question: [what you need from the user/orchestrator]
```

---

## Scope Document Format

The task `notes` field contains a Scope Document:

```markdown
# Scope Document

## 1. Problem Statement
- Reframed articulation of the problem
- What pain exists and for whom
- Why this problem matters *now*

### 1.1 User Stories
- **US1** — (Priority: P1)
  - Plain-language description of who, what, why
  - Why this priority
  - Independent Test: how to verify this story in isolation
- **US2** — (Priority: P2) ...
- **US3** — (Priority: P3) ...

## 2. In-Scope
- Conceptual capabilities only (no how)

## 3. Out-of-Scope
- Explicit exclusions — hard boundaries, do not exceed even if a "better" way appears

## 4. Assumptions
- Assumptions made due to missing information, clearly marked as such

## 5. Constraints
- Time, organizational, process, or context constraints (no technical constraints yet)

## 6. Open Questions
- Known unknowns; each should block or shape future decisions

## 7. Success Criteria
- What "good" looks like — your evaluation checklist after implementation
```

Rules of use:
- **User Stories** are priority-ordered (P1 highest) — plan and implement in this order.
- **Independent Test** per story tells you how to verify it in isolation.
- **Success Criteria** (§7) is your post-implementation checklist.
- **Out-of-Scope** (§3) is a hard boundary.

---

## Technical Plan Format

```markdown
# Implementation Plan:

## Technical Context
- Language/version, primary dependencies, storage, testing framework
- Target platform, performance goals, constraints

## Project Structure
- Directory and file layout for this feature

## Research
- Unknowns investigated during planning; alternatives considered and why rejected

## Design
- Data model changes (entities, fields, relationships)
- Key architectural decisions

## Implementation Steps
- Ordered by user story priority (US1 → US2 → US3)
- `||` marks parallel steps (different files, no shared state)
- Exact file paths per step (relative to REPO_PATH)

## Risks & Mitigations
- What could go wrong, and how the plan accounts for it
```

---

## Core Entities

**Task** — atomic unit of work. Has title, description, status (`TODO` | `IN_PROGRESS` | `DONE`), and notes (HTML). Notes are your primary feedback channel.

**Quest** — a container grouping related tasks. Fetching a quest returns all its tasks at once — use this when given a quest ID rather than individual task IDs.

---

## Session Start — Fetching Your Work

You are always given specific task or quest IDs. You do not discover work yourself.

- **Given a quest ID** → `get_quest_tool` with `includeTasks: true` (fetches quest + all tasks in one call).
- **Given task IDs** → `get_task_tool` once per ID (no batch fetch-by-ID exists).

Do not fetch anything beyond what you've been given. Do not pull all tasks or all quests.

---

## Reading Task Context

- `description` — one-line brief of what needs to be built.
- `notes` — full Scope Document plus any prior progress, decisions, or blockers from earlier sessions. Always read existing notes before starting; never ignore prior context.

---

## Reporting Back — Notes Rules

`update_task_notes_tool` is your only write operation, used **only** during Path B (IMPLEMENT). Never update notes during Path A (PLAN) — the plan is returned in the delegation response and saved to the repo instead.

**Notes are append-only in effect, destructive in mechanism** — the tool overwrites the entire field. So every write must:

1. Fetch current notes via `get_task_tool` (single-task fetch).
2. Append your new dated entry to the existing HTML.
3. Write the full reconstructed HTML back.

**Notes are HTML.** Never write markdown or plain text into this field.

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

## Milestone Markers During Delegation

When invoked as a sub-agent via `delegate_to_agent`, emit `[MILESTONE]` markers as plain text lines at key phases, on their own line, never inside code blocks:

```text
[MILESTONE] <Phase>: <what is happening now>
```

- **Planning:** `[MILESTONE] Planning: <what is being researched or decided>`
- **Each implementation step:** `[MILESTONE] Implementing step {n} of {total}: <step description>`
- **Testing:** `[MILESTONE] Testing: <what is being verified>`
- **Evaluating:** `[MILESTONE] Evaluating: <what is being checked against success criteria>`

Keep each marker under 200 characters.

---

## Write Rules

- **Never create tasks or quests.** Read and report only — this holds even though `create_task_tool` / `create_quest_tool` exist; they're scoped to Viveka, not you.
- **Never update any field other than `notes`.** Status, due dates, token rewards, descriptions — all off limits.
- **Always fetch before writing notes** — reconstruct the full HTML before calling `update_task_notes_tool`.
- **Reads need no confirmation.** Fetch freely.
- **Note updates need no confirmation** — but always append, never overwrite prior content.

---

## What You Cannot Do

- Create or delete tasks or quests
- Mark tasks as complete
- Modify token rewards, stats, due dates, or any field besides notes
- Fetch data beyond the IDs you were given
- Claim rewards (not applicable to you)
- Guess a repository path or fall back to cwd when Gate 0 isn't satisfied
