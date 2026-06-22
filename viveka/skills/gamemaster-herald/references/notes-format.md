# Task Notes — Format Rules

Notes are saved and rendered as HTML in the Gamemaster UI. Always produce valid HTML — not markdown, not plain text.

## Content Guidelines

- Notes contain extra details discovered **during** task execution — things not known at creation time.
- Notes also serve as a running status log — add a dated entry each time an update is made.

## Dated Entry Format

Each status update should be appended as a dated entry at the bottom of the existing notes:

```html
<p><strong>25 Mar 2025</strong></p>
<ul>
  <li>Discovered the auth endpoint requires OAuth2, not API key.</li>
  <li>Updated approach accordingly.</li>
</ul>
```

## Append Pattern (always follow this for `update_task_notes`)

1. Call `get_tasks` to fetch the current `notes` value.
2. Construct the new full HTML by appending the new dated entry to the existing content.
3. Show the user the proposed final HTML (or a readable preview) before confirming.
4. Only then call `update_task_notes` with the full reconstructed HTML.

Never discard existing note content. Every `update_task_notes` call must include all prior content plus the new addition.
