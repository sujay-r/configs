# Write Tool Rules

These rules are strict and must be followed without exception.

### Rule 1: Always preview before acting

Before calling any write tool, present the exact action you intend to take in
plain language. Show every field you plan to write. Do not proceed until the
user gives explicit confirmation.

**Example — task creation:**
> I'll create the following task:
> - **Title:** Draft API spec
> - **Quest:** Backend (id: 42)
> - **Notes:** Focus on auth endpoints first
>
> Shall I go ahead?

Only call `task_create` after a clear yes ("yes", "go ahead", "do it",
"confirm").

### Rule 2: Never infer token rewards

Do not assign `token_reward` values unless the user explicitly specifies them.
Token values carry gameplay meaning — silent defaults corrupt the system. If the
user does not mention tokens, omit the field.

### Rule 3: Suggest freely, act only on confirmation

Proactively suggesting a task or quest is fine; a suggestion is not an action.
Only write after explicit confirmation.

### Rule 4: Batch updates are one preview, one call

`task_update` is list-shaped. Collect every task change into **one** batch, show
one consolidated preview, get one confirmation, then make one call. Never fire a
write per task while gathering information.

- `notes` **replaces** the whole note body and is destructive. Use it only when
  the user asks for a rewrite, and show the before/after.
- `note_append` **appends** a server-generated dated entry. It is the default
  path: you send only the new body and never need to read or reconstruct the
  note first.
- `notes` and `note_append` are mutually exclusive per item.
- A batch containing an invalid item is rejected in full, so fix the offending
  IDs rather than retrying items one by one.

### Rule 5: Never claim rewards

Rewards are claimed by the user only. There is no MCP tool for claiming them,
and you must never suggest or attempt it.

### Rule 6: `tags` is replace-all

`tags` on `task_update` or `quest_update` replaces the entire tag set — it does
not append. Before calling, fetch the current tags (`tasks_list(ids=[...])` or
`quest_get`) and show the current set beside the proposed new set. Send `[]` to
clear all tags. Confirm before proceeding.

### Rule 7: `task_update(status="DONE")` is gated to `opencode` tasks

A DONE transition is refused for any task that does not carry the `opencode`
tag. The tag marks work actually delegated to a coding agent.

- Because updates are batched, the gate is **all-or-nothing**: one untagged DONE
  item rejects the whole call, nothing is written, and the error names the
  offending task IDs.
- Verify tags before composing the batch (`tasks_list(ids=[...])`). If a task
  should be closed but lacks the tag, ask the user whether to attach it first.
- Always ask for explicit confirmation before **any** status change — even
  TODO → IN_PROGRESS.

### Rule 8: Quests are mutable — treat with the same care

`quest_update` can activate a backlog quest, complete a quest, rename it, change
its type, replace tags, or amend notes. Changing status is a user-visible
lifecycle action: preview it and confirm explicitly. `updated_at` bumps on every
update.

### Rule 9: Writes return receipts, not records

Every write responds with `{id, title, status, changed[]}` (or
`{receipts, count}` for `task_update`) — never the notes body. A receipt confirms
the write landed; it is not a read. If you need to show the resulting content,
fetch it back with `task_get(include=["notes"])` or `detail="full"`.
