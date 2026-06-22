# Delegating to OpenCode via Gamemaster

Load this reference when the user asks to delegate coding work to OpenCode.

---

## The Pipeline

```text
SCOPE → DELEGATE:PLAN → REVIEW → DELEGATE:IMPLEMENT → EVALUATE → REPORT
```

---

## Stage 1 — SCOPE (You + User)

The user describes the feature. You help refine it into a **Scope Document** using the template below. This goes into the task `notes` field.

### Scope Document Template

```markdown
# Scope Document

## 1. Problem Statement

- Reframed articulation of the problem
- What pain exists and for whom
- Why this problem matters *now*

### 1.1 User Stories

- **US1** — [Brief Title] (Priority: P1)
  - Plain-language description of who, what, why
  - Why this priority
  - Independent Test: How to verify this story works in isolation

- **US2** — [Brief Title] (Priority: P2)
  - ...

- **US3** — [Brief Title] (Priority: P3)
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

After writing the scope, tag the task `opencode` — either by passing `tags: ["opencode"]` at task creation or using `set_task_tags` on an existing task. Then delegate via the `delegate_to_agent` tool.

Instruct it to fetch the task ID only, do not provide any additional context — OpenCode will fetch the task and its scope document from Herald.

---

## Stage 2 — DELEGATE: PLAN

OpenCode fetches the task, reads the Scope Document from `notes`, and produces a technical plan.

It creates the directory:

```text
specs/<task-title-slug>/
```

and saves the plan to:

```text
specs/<task-title-slug>/plan.md
```

The plan is returned in the delegation response.

OpenCode does **NOT** update task notes at this stage.

### Response Protocol

OpenCode's response will begin with one of these status headers.

#### Plan Ready

```text
STATUS: PLAN_READY

[Full technical plan]

Saved to specs/<task-title-slug>/plan.md
```

#### Blocked

```text
STATUS: BLOCKED

Issue: [What went wrong]

Question: [What needs answering before continuing]
```

If the response has no `STATUS:` header, treat it as an error.

### Technical Plan Format

OpenCode produces plans using this structure:

```markdown
# Implementation Plan: [Task Title]

## Technical Context

- Language/version, primary dependencies, storage, testing framework
- Target platform, performance goals, constraints

## Project Structure

- Directory and file layout for this feature

## Research

- Unknowns investigated during planning
- Alternatives considered and why rejected

## Design

- Data model changes (entities, fields, relationships)
- Key architectural decisions

## Implementation Steps

- Ordered by user story priority (US1 → US2 → US3)
- [P] for parallel steps (different files, no shared state)
- Exact file paths per step

## Risks & Mitigations

- What could go wrong
- How the plan accounts for it
```

---

## Stage 3 — REVIEW (Viveka)

Read the returned technical plan.

Sanity-check it against the Scope Document:

- Does it cover all user stories (US1, US2, US3)?
- Are out-of-scope boundaries respected?
- Are success criteria addressed in the implementation steps?
- Are file paths and project structure sensible?

If issues exist, flag them to the user and iterate via another delegation call.

If the plan is sound, tell the user it's approved and ready for implementation.

---

## Stage 4 — DELEGATE: IMPLEMENT

A separate delegation call.

Pass the same task ID — OpenCode will detect:

```text
specs/<task-title-slug>/plan.md
```

exists and switch to Path B (IMPLEMENT).

---

## Stage 5 — EVALUATE (OpenCode)

OpenCode tests the implementation against Section 7 (Success Criteria) from the Scope Document.

This happens automatically — you don't need to instruct it.

---

## Stage 6 — REPORT (OpenCode)

OpenCode writes a structured dated entry into task notes with:

- What was implemented and key decisions
- Test results against success criteria (pass/fail per criterion)
- Any deviations from the plan and why
- Known issues or follow-up items

---

## Task Description — What Goes Here

The `description` field is a one-line brief of what needs to be built — just enough for quick scanning.

The Scope Document in `notes` is the full specification.

---

## After Delegation

The `opencode` tag is an audit marker.

It does not replace the explicit `delegate_to_agent` call.

---

## Closing Delegated Tasks

After OpenCode reports back via a `STATUS:` header and the user confirms the work is complete, call `update_task_status` to mark the task DONE. The tool enforces the `opencode` gate — you can only close tasks that were explicitly delegated.

---

## Error Handling

### STATUS: BLOCKED

Relay the issue and question to the user.

The user answers, then re-delegate to continue planning.

### No STATUS Header

Something went off-script.

Tell the user and consider re-delegating with explicit instructions.

### Plan Has Gaps

Tell the user what's missing and iterate with another PLAN delegation.
