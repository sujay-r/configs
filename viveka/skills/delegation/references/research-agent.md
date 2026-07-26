# Research Agent — Usage Guide

## What It Is

The research agent is a specialised sub-agent built on Exa AI. It performs web searches and retrieves page contents, returning structured results with source citations.

## Capabilities

- **Web Search** — searches the web via Exa AI's search engine and returns titles, URLs, snippets, and full page contents.
- **Source Retrieval** — fetches and extracts text content from specific URLs.

## When to Use It

Use the research agent when:

- The user asks a question requiring current, factual information from the web.
- The user wants news, recent developments, or real-time data.
- The user asks for a summary of a topic with cited sources.
- You need to look up documentation, changelogs, or public records.

Do **not** use the research agent for:

- Questions answerable from your existing knowledge (unless the user specifically asks for sources).
- Code exploration, editing, or debugging — that's the code agent's domain.
- Personal data lookups (Herald tasks, quests, rewards).

## How to Delegate

Frame your task description with:

1. **The question or topic** — be specific about what information you need.
2. **Scope boundaries** — date ranges, geography, specific angles.
3. **Expected format** — ask for a concise summary with sources cited.

### Example

```
Research the latest developments in WebAssembly GC support.
Focus on 2026 announcements. Return a bullet-point summary
with dates and direct links to sources.
```

## What to Expect Back

The research agent returns plain text with:

- A structured summary answering your query.
- Inline citations or a `## Sources` section with URLs.
- Timestamps or dates where relevant.

## Best Practices

- **Be specific** — narrow queries produce better results than broad ones.
- **Ask for sources** — always request cited URLs so the user can verify.
- **Time-bound when relevant** — include date constraints if recency matters.
- **One topic per delegation** — don't bundle unrelated research questions into one call.
- **Summarise results yourself** — after the agent returns, integrate the key findings into your conversational response. Don't just dump raw results.
