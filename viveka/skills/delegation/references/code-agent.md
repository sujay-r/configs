# Code Agent (OpenCode) — Usage Guide

## What It Is

OpenCode is a specialised coding agent. It explores codebases, writes and edits code across files, runs builds and tests, and manages the full development lifecycle. It operates from a parent `Code` directory containing multiple repositories.

## Capabilities

- **Code Exploration** — navigate and understand existing codebases. List directories, read files, search for patterns.
- **Code Editing** — write and modify code across multiple files in a repository.
- **Debugging** — diagnose and fix bugs by reading error output, tracing code, and applying targeted fixes.
- **Testing** — run test suites and interpret results.
- **Build Verification** — run type-checks, builds, and linting.

## When to Use It

Use OpenCode when:

- The user asks you to implement a feature, fix a bug, or refactor code.
- The user wants a codebase explored or understood.
- The user needs a build, test, or type-check run against a specific repository.
- The user delegates a task tagged `opencode` — this is the primary signal.

Do **not** use OpenCode for:

- Quick filesystem reads or writes that you can do directly with your own tools.
- Web research or information retrieval — that's the research agent's domain.
- Task/quest management via Herald — you handle those yourself.

## Coding Workflow — Gamemaster Pipeline (DEFAULT)

**All coding tasks follow the Gamemaster delegation pipeline. This is the default and preferred approach. Only deviate if the user explicitly requests a different workflow.**

### Before Delegating

Load the pipeline reference from the Gamemaster Herald skill:

```
load_skill_reference("gamemaster-herald", "opencode-delegation.md")
```

The pipeline has 7 stages:

| Stage | Owner | What Happens |
|---|---|---|
| **1. SCOPE** | You + User | Refine the feature into a Scope Document; write it to task `notes` |
| **2. RESOLVE REPO** | You | Determine the absolute path to the target repository |
| **3. DELEGATE: PLAN** | You → OpenCode | Send `Task: <id>` + `Repository: <path>`; OpenCode produces a technical plan |
| **4. REVIEW** | You | Sanity-check the plan against the Scope Document |
| **5. DELEGATE: IMPLEMENT** | You → OpenCode | Same two-line format; OpenCode detects the plan and implements |
| **6. EVALUATE** | OpenCode | Runs tests against Success Criteria |
| **7. REPORT** | OpenCode | Writes a dated results entry to task `notes` |

### Key Rules

1. **Every delegation call must include `Repository:`** — the path is not persisted. Omitting it triggers a `BLOCKED` response.
2. **The delegation call is exactly two lines** — nothing else:

   ```
   Task: <task-id>
   Repository: /absolute/path/to/repo
   ```

3. **Scope Document goes in task `notes`** — not in the delegation call. OpenCode fetches the task itself.
4. **Review before implementing** — never skip Stage 4. A bad plan produces bad code.
5. **Close the task after confirmation** — once the user confirms the work is done, call `update_task_status` to mark it DONE (only works on `opencode`-tagged tasks).

### Response Protocol

OpenCode responds with a `STATUS:` header:

- **`STATUS: PLAN_READY`** — plan is complete and saved. Proceed to Stage 4 (review).
- **`STATUS: BLOCKED`** — something went wrong. Read the `Issue:` and `Question:` lines.
  - If the issue is a missing/ambiguous repo path, fix it yourself (Stage 2) and re-delegate.
  - Otherwise, relay to the user and iterate.
- **No `STATUS:` header** — treat as an error; inform the user and consider re-delegating.

## OpenCode vs. Filesystem Tools

You have your own filesystem tools (`read_file`, `write_file`, `search_files`, etc.). This table helps you decide which to use:

| Situation | Use |
|---|---|
| Quick read of one known file | Your own `read_file` |
| Create a small file (< 50 lines) | Your own `write_file` |
| Explore an unfamiliar codebase | Delegate to OpenCode (`STATUS: PLAN_READY` first) |
| Multi-file feature implementation | Delegate to OpenCode via the pipeline |
| Debug a complex issue | Delegate to OpenCode |
| Run a build or test suite | Delegate to OpenCode |
| Search across a large codebase | Delegate to OpenCode |

**Rule of thumb**: If it's more than one file or requires understanding the codebase architecture, delegate it.

## Timeouts

OpenCode tasks can take several minutes. The delegation call has a 300-second timeout. If it times out, check the task notes — OpenCode may have completed the work and written results before the timeout fired. Do not re-delegate without checking first.
