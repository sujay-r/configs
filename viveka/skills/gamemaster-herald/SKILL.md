---
name: gamemaster-herald
description: >
  Use this skill whenever the user asks anything related to Gamemaster — their tasks, quests,
  stats, tokens, rewards, or daily progress. Also use it when the user asks you to create a task,
  update task notes, or check what they're working on today. This skill provides both background
  context on what Gamemaster is and strict usage rules for the Herald MCP tools. Always consult
  this skill before making any Herald tool call, even for simple reads.
compatibility:
  required_tools:
    - Herald MCP (gamemaster-herald)
---

# Gamemaster – Herald Skill

## What is Gamemaster?

Gamemaster is a personal productivity PWA built around RPG mechanics. The user manages their life through a system of tasks, quests, stats, and token rewards. It is intentionally playful but not over-gamified — the goal is low-friction, meaningful progress tracking.

### Core Entities

**Task** — an atomic action item. Has a title, optional description, status (`TODO` | `IN_PROGRESS` | `DONE`), optional token reward, optional notes (HTML), and an optional link to a Quest.

**Quest** — a container grouping related tasks. Has a status (`todo` | `completed`). Quests do not directly generate rewards.

**Resource** — represents the user's character state, split into two categories:
- *Tokens* (`Care`, `Grind`) — automated, earned by completing tasks, spent on rewards.
- *Stats* (`Health`, `Mood`, `Focus`, `Energy`) — manually updated by the user to encourage reflection. May have buffs and debuffs attached.

**Reward** — a claimable benefit purchased with tokens. Can only be claimed by the user directly — never by an agent.

### Gameplay Loop

1. User completes tasks → earns Care / Grind tokens automatically.
2. User spends tokens to claim rewards.
3. User manually reflects on and adjusts stats.
4. Today's Log resets at midnight.

---

## What You Cannot Do

- Delete any entity — ever.
- Update arbitrary task fields like title, description, or token rewards.
- Mark a task DONE unless the user explicitly confirms and the task carries the `opencode` tag (enforced by the tool itself, but you must still follow write rules).
- Modify token balances, stats, buffs, or debuffs.
- Claim rewards.
- Create quests (future scope, not yet available).
- Write anything without explicit user confirmation.

---

## References

Load these only when the relevant action arises:

- `references/tools.md` — available Herald tools and awareness mode guidance. Load when the user asks about their tasks, quests, stats, or daily progress.
- `references/write-rules.md` — rules for safe write operations. Load before calling `create_task` or `update_task_notes`.
- `references/notes-format.md` — HTML format rules and append pattern for task notes. Load before writing or updating any task notes.
- `references/opencode-delegation.md` — how to write tasks/quests for OpenCode delegation. Load when creating tasks intended for a coding agent.
