---
name: agent-summary
description: Summarize the last agent output with appropriate depth, optionally play as voice
user_invocable: true
---

# Agent Summary

Generate a concise explanation of what the last completed agent did, why, and how it affects the project.

## Instructions

1. Read the most recent task notification in the conversation
2. Classify the work:
   - **Business**: product decisions, PM specs, roadmap → explain impact and strategic reasoning
   - **Architecture**: design patterns, refactors → explain the pattern, why it was chosen, trade-offs
   - **Implementation**: feature code, bug fixes → explain what changed, what it fixes, testing status
   - **QA**: tests written/fixed → explain coverage, what's now protected, remaining gaps
3. Generate a 3-5 sentence summary in the user's working language
4. Write the summary to `/tmp/claude-voice-summaries/latest_summary.txt`
5. Run voice playback: `<project-root>/tooling/scripts/voice-summary.sh /tmp/claude-voice-summaries/latest_summary.txt <lang>`
   - The script reads `$VOICE_SUMMARY` env var (off|headphones|all) and handles the gate logic
   - You don't need to check headphones — the script does it
6. Always display the text summary in the conversation regardless of voice

## Output format

```
## Resumen del agente

[3-5 sentence summary]

Tipo: [Business | Architecture | Implementation | QA]
Archivos: [count] modificados
Impacto: [LOW | MEDIUM | HIGH | CRITICAL]
```
