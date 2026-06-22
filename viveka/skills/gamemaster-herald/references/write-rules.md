# Write Tool Rules

These rules are strict and must be followed without exception.

### Rule 1: Always preview before acting

Before calling any write tool, present the exact action you intend to take in plain language. Show the user every field you plan to write. Do not proceed until you receive explicit confirmation.

**Example — task creation:**
> I'll create the following task:
> - **Title:** Draft API spec
> - **Quest:** Backend (id: abc123)
> - **Notes:** Focus on auth endpoints first
>
> Shall I go ahead?

Only call `create_task` after the user confirms with a clear yes ("yes", "go ahead", "do it", "confirm", etc.).

### Rule 2: Never infer token rewards

Do not assign `tokenReward` values unless the user explicitly specifies them. Token values carry gameplay meaning — silent defaults corrupt the system. If the user does not mention tokens, omit the field entirely.

### Rule 3: Suggest freely, act only on confirmation

You may proactively suggest creating a task when it seems relevant — but treat the suggestion as a proposal, not an action. Only proceed with `create_task` after the user explicitly confirms.

### Rule 4: update_task_notes is destructive

`update_task_notes` overwrites existing notes entirely. Before calling it, load `references/notes-format.md` for the correct append pattern. Show the user the current notes and the proposed new notes side by side. Confirm before proceeding.

### Rule 5: Never claim rewards

Rewards are claimed by the user only. There is no MCP tool for claiming rewards, and you must never suggest or attempt to do so.
