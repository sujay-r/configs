# Delegating to OpenCode via Gamemaster

Load this reference when the user asks to delegate coding work to OpenCode.

---

## The Pipeline

```text
SCOPE → RESOLVE REPO → DELEGATE:PLAN → REVIEW → DELEGATE:IMPLEMENT → EVALUATE → REPORT
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

After writing the scope, tag the task `opencode` — either by passing `tags: ["opencode"]` at task creation or using `set_task_tags` on an existing task.

---

## Stage 2 — RESOLVE REPOSITORY (Viveka)

OpenCode is started from a parent `Code` directory containing multiple repositories. It has no way to know which one a task targets unless you tell it — **on every delegation call**, not just the first.

**Before the first `delegate_to_agent` call, determine the target repository yourself.** List the repos under the parent `Code` directory, then match against the Scope Document and task/quest context from Stage 1, in this order — stop at the first that produces exactly one match:

1. **Exact directory name** — does a repo directory name match a project name mentioned in the scope conversation?
2. **Manifest name** — does a `package.json` / `pyproject.toml` / `Cargo.toml` (etc.) name field match?
3. **README content** — does a repo's README describe the project referenced in the scope?
4. **Git remote** — does a remote URL match a project name or org referenced in the scope?

Resolve to a single absolute path, e.g. `/home/user/Code/viveka-core`.

**Do not guess past this chain — the failure mode determines the question:**

- **Multiple repos still match** after all four steps → ask the user which one they mean.
- **Zero repos match** → don't assume that means "create a new one." Ask the user directly: does this target an existing repo you haven't found, or should a new one be created?

**Standing invariant:** a resolved, absolute `Repository:` path is a hard precondition for delegation — same tier as the `opencode` tag. There is no delegation call, PLAN or IMPLEMENT, without one.

Once resolved, hold this path for the task's lifetime — you'll need it again at Stage 5 (DELEGATE:IMPLEMENT), since it is **not** persisted anywhere and must be re-supplied on every delegation call for this task.

---

## Stage 3 — DELEGATE: PLAN

The delegation prompt contains exactly two things — nothing else, no additional scope detail, no restating of context OpenCode can fetch itself:

```text
Task: <task-id>
Repository: /absolute/path/to/repo
```

OpenCode fetches the task, reads the Scope Document from `notes`, and produces a technical plan.

It creates the directory:

```text
<Repository>/specs/<task-title-slug>/
```

and saves the plan to:

```text
<Repository>/specs/<task-title-slug>/plan.md
```

The plan is returned in the delegation response. OpenCode does **NOT** update task notes at this stage.

### Response Protocol

OpenCode's response will begin with one of these status headers.

#### Plan Ready

```text
STATUS: PLAN_READY

[Full technical plan]

Saved to <Repository>/specs/<task-title-slug>/plan.md
```

#### Blocked

```text
STATUS: BLOCKED

Issue: [What went wrong]

Question: [What needs answering before continuing]
```

If the response has no `STATUS:` header, treat it as an error.

A `BLOCKED` response with an issue naming a missing or ambiguous repository path means Stage 2 wasn't completed correctly — resolve it and re-delegate rather than pushing the question to the user unchanged.

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

## Stage 4 — REVIEW (Viveka)

Read the returned technical plan.

Sanity-check it against the Scope Document:

- Does it cover all user stories (US1, US2, US3)?
- Are out-of-scope boundaries respected?
- Are success criteria addressed in the implementation steps?
- Are file paths and project structure sensible, and rooted under the resolved repository?
- **Does the "Saved to" path in the plan match the exact `Repository:` value you sent?** If OpenCode's plan references a different repo path than what was delegated, treat this as drift, not a minor discrepancy — flag it and re-delegate rather than approving.

If issues exist, flag them to the user and iterate via another delegation call.

If the plan is sound, tell the user it's approved and ready for implementation.

---

## Stage 5 — DELEGATE: IMPLEMENT

A separate delegation call, same two-line template as Stage 3 — the `Repository:` line is not remembered from the PLAN call, so omitting it here will re-trigger a `BLOCKED` response:

```text
Task: <task-id>
Repository: /absolute/path/to/repo
```

OpenCode will detect:

```text
<Repository>/specs/<task-title-slug>/plan.md
```

exists and switch to Path B (IMPLEMENT).

---

## Stage 6 — EVALUATE (OpenCode)

OpenCode tests the implementation against Section 7 (Success Criteria) from the Scope Document.

This happens automatically — you don't need to instruct it.

---

## Stage 7 — REPORT (OpenCode)

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

It does not replace the explicit `delegate_to_agent` call, and it does not replace the `Repository:` line — the tag says work was delegated, not where.

---

## Closing Delegated Tasks

After OpenCode reports back via a `STATUS:` header and the user confirms the work is complete, call `update_task_status` to mark the task DONE. The tool enforces the `opencode` gate — you can only close tasks that were explicitly delegated.

---

## Error Handling

### STATUS: BLOCKED

Relay the issue and question to the user — unless the issue is a missing/ambiguous repository path, which is a Stage 2 failure on your end and should be fixed and re-delegated, not bounced to the user as-is.

The user answers, then re-delegate to continue planning.

### No STATUS Header

Something went off-script.

Tell the user and consider re-delegating with explicit instructions.

### Plan Has Gaps

Tell the user what's missing and iterate with another PLAN delegation.
