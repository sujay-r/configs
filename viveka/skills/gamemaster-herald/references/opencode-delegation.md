# Delegating to OpenCode via Gamemaster

Load this reference when the user asks to delegate coding work to OpenCode.

---

## The Pipeline

SCOPE → DELEGATE:PLAN → REVIEW → DELEGATE:IMPLEMENT → EVALUATE → REPORT

---

## Stage 1 — SCOPE (You + Viveka)

The user describes the feature. You help refine it into a **Scope Document** using the template below. This goes into the task `notes` field.

### Scope Document Template

```
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

After writing the scope, tag the task `opencode` and delegate via the `delegate_to_agent` tool.

---

## Stage 2 — DELEGATE: PLAN

OpenCode fetches the task and its Scope Document from Herald. It produces a technical plan saved to:

`specs/<task-title-slug>/plan.md`

The plan covers architecture, data model, implementation approach, and any research decisions.

OpenCode returns the plan in the `delegate_to_agent` response. No notes update at this stage.

---

## Stage 3 — REVIEW (Viveka)

You read the returned technical plan and sanity-check it against the Scope Document. If issues exist, flag them and iterate via another delegation call. If the plan is sound, approve it.

---

## Stage 4 — DELEGATE: IMPLEMENT

A separate delegation call. OpenCode implements per the approved plan.

---

## Stage 5 — EVALUATE (OpenCode)

OpenCode tests the implementation against Section 7 (Success Criteria) from the Scope Document.

---

## Stage 6 — REPORT (OpenCode)

OpenCode writes a structured outcome update into the task notes using the dated-entry format (see `references/notes-format.md`).

The report should include:

- What was implemented
- Test results against success criteria
- Any deviations from the plan and why
- Known issues or follow-up items

---

## Task description — what goes here

The `description` field is a one-line brief of what needs to be built — just enough for quick scanning. The Scope Document in `notes` is the full spec.

---

## After delegation

The `opencode` tag is an audit marker. It does not replace the explicit `delegate_to_agent` call.
