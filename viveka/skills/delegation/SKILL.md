---
name: delegation
description: >
  General guidance for delegating tasks to specialised sub-agents via A2A.
  Available agents: research (web research and source retrieval via Exa AI)
  and code (OpenCode — full coding lifecycle including code exploration,
  editing, and debugging). Load per-agent references under references/ for
  detailed workflows and best practices.
compatibility:
  required_tools:
    - delegate_to_agent
---

# Delegation Skill

## Available Sub-Agents

- **research** — Web research and source retrieval via Exa AI. Load `references/research-agent.md` for detailed capabilities, when to use, and best practices.
- **code** — OpenCode agent for all coding tasks. Coding delegation follows the **Gamemaster pipeline**. Load `references/code-agent.md` for capabilities and the Gamemaster × OpenCode workflow instructions.

## When to Delegate

Delegate to a sub-agent when the user's request clearly falls within a speciality that another agent is optimised for. Common signals:

- The task requires a distinct workflow or domain knowledge (e.g., research, coding).
- The task is self-contained enough to hand off and wait for a result.
- Keeping the task in your own context would add noise or exceed the useful context window.

Do not delegate for trivial one-line answers or when the user explicitly asked you to perform the action yourself.

## How to Delegate

1. Confirm the user's goal and any constraints.
2. Choose the most appropriate `agent_name` from the **Available Sub-Agents** list above. Load the corresponding per-agent reference for detailed workflow instructions.
3. Write a clear, self-contained `task` description. Include relevant file paths, context, and the expected return format.
4. Call `delegate_to_agent`.
5. Integrate the sub-agent's response into your final answer. Do not simply echo it unless the user asked for a raw dump.

## Progress Markers

When delegating to a streaming-capable sub-agent, milestone markers (`[MILESTONE] Phase: description`) may be emitted. Surface meaningful progress to the user if appropriate, but do not interrupt the sub-agent.

## Return Format

The sub-agent returns its final response as plain text. Treat it as you would any tool result: verify it answers the user's request, cite sources if it provided them, and present it concisely.
