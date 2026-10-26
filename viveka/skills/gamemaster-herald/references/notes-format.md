# Task Notes — Format Rules

Write notes as Markdown. Herald converts them to HTML before saving, and the
Gamemaster UI renders the stored HTML. You never need to write HTML — do not send
HTML tags, and do not send plain text without Markdown structure.

## Content Guidelines

- Notes contain extra details discovered **during** task execution — things not
  known at creation time.
- Notes also serve as a running status log — add a dated entry each time an
  update is made.

## Dated Entry Format

Each status update is appended as a dated entry at the bottom of the existing
notes:

```markdown
**25 Mar 2025**

- Discovered the auth endpoint requires OAuth2, not API key.
- Updated approach accordingly.
```

## `note_append` — the preferred path

`note_append` moves the append server-side. The server builds the `**25 Mar
2025**` heading and appends after existing content with a blank-line separator.

1. Send only the **new Markdown body** (typically a bullet list) — omit the dated
   heading; the server adds it.
2. Use the current date unless the user specifies otherwise. If the user wants a
   specific date, they can ask for a full `notes` replacement instead.
3. Show the proposed body in the write preview, get confirmation, then include
   it as `{"id": N, "note_append": "..."}` in the `task_update` batch.
4. Existing content is never discarded. You do **not** need to read the note
   first, and you must not reconstruct it.

```json
{"id": 42, "note_append": "- **Update:** the OAuth2 flow is working end to end."}
```

## Full replacement (`notes`) — exceptional

`notes` overwrites the entire note body. Use it only when the user explicitly
asks to rewrite or restructure notes. Before calling it:

1. Fetch the current notes with `task_get(task_id, include=["notes"])`.
2. Show the current Markdown and the proposed replacement side by side.
3. Confirm, then send the complete new Markdown in `task_update`.

Never use `notes` merely to add something; that is what `note_append` is for.
`notes` and `note_append` cannot be combined on the same item.
