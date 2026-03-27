---
name: vsm-summary
description: Voice narration for agent completions, session milestones, questions, and decisions
user_invocable: true
---

# Voice Summary

Voice narration for everything happening in a Claude Code session. Not just results — also questions, decisions, and explanations.

## When to narrate

- **Agent completion**: background task finished — what it did, result
- **Session milestone**: build passed, tests ran, PR created, deploy finished
- **Question to user**: Claude or an agent needs a decision — narrate the question
- **Decision made**: user chose an option — confirm what was decided
- **Error/blocker**: something failed — explain what and next steps

## Depth levels (`VOICE_DEPTH` env var)

| Level | What you hear |
|-------|---------------|
| `info` | Results only: "Agent done. 1354 tests, 0 failures." |
| `detail` | Results + context: "Agent fixed 25 tests. Root cause was the regex missing a word boundary. No regressions." |
| `explain` | Full explanation: architecture decisions, why patterns were chosen, how the code works, trade-offs considered |

## Instructions

1. Read `$VOICE_DEPTH` env var (default: `detail`)
2. Identify what just happened (see "When to narrate" above)
3. Generate the narration text at the appropriate depth:
   - `info`: 1-2 sentences, facts only
   - `detail`: 2-4 sentences, facts + context
   - `explain`: 4-8 sentences, facts + context + reasoning + how it works
4. For **questions**: always narrate regardless of depth — the user needs to hear them
5. Write to `/tmp/claude-voice-summaries/latest_summary.txt`
6. Run: `<project-root>/tooling/scripts/voice-summary.sh /tmp/claude-voice-summaries/latest_summary.txt <lang>`
7. Always display text in conversation regardless of voice

## Output format

```
## Resumen

[narration text at appropriate depth]

Tipo: [Business | Architecture | Implementation | QA | Ops | Question | Decision]
```
