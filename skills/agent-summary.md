---
name: agent-summary
description: Voice summary for agent completions AND session milestones — reads aloud through headphones
user_invocable: true
---

# Voice Summary

Generate a concise voice summary of what just happened in the session. Works for both agent completions and main session milestones.

## When to use

- After an agent completes a background task (task notification received)
- After a significant session milestone (build passed, tests ran, PR created, deploy finished)
- After a complex multi-step operation completes
- When the user invokes `/agent-summary` manually

## Instructions

1. Identify what just completed:
   - **Agent completion**: read the task notification result
   - **Session milestone**: summarize the action and its outcome (build result, test count, deploy status)
2. Classify the work:
   - **Business**: product decisions, PM specs, roadmap
   - **Architecture**: design patterns, refactors, new abstractions
   - **Implementation**: feature code, bug fixes, UI changes
   - **QA**: tests written/fixed, coverage changes
   - **Ops**: builds, deploys, CI/CD, PR operations
3. Generate a 2-4 sentence summary in the user's working language
   - Be concise — this will be spoken aloud
   - Lead with what happened, then why it matters
   - Include numbers when relevant (test count, files changed, duration)
4. Write the summary to `/tmp/claude-voice-summaries/latest_summary.txt`
5. Run: `<project-root>/tooling/scripts/voice-summary.sh /tmp/claude-voice-summaries/latest_summary.txt <lang>`
   - The script handles headphone detection and mode gating via `$VOICE_SUMMARY`
6. Always display the text summary in the conversation regardless of voice

## Output format

```
## Resumen

[2-4 sentence summary]

Tipo: [Business | Architecture | Implementation | QA | Ops]
Impacto: [LOW | MEDIUM | HIGH | CRITICAL]
```
