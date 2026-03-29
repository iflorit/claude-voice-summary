# Claude Code Voice Summary

> **Hear what Claude is doing.** Voice summaries for Claude Code -- agent completions, session milestones, status updates. Plays through your headphones automatically, never interrupts through speakers unless you want it to.

```
Agent completed: "Refactored the auth module into 3 files with DI protocols"
Session milestone: "Build passed, 1347 tests, 0 failures"
     |
     v
 [edge-tts] --> [headphones] --> You hear the summary while working
```

---

## Why

When Claude Code runs long tasks -- background agents, builds, test suites -- you context-switch. When they finish, you have to read the output to understand what happened. **Voice Summary reads it to you** -- so you stay in flow.

- Agent finishes a 5-minute refactor? Hear a 10-second summary.
- Three agents complete in parallel? Three summaries, queued.
- Build passes after fixing 25 tests? "Build green, all tests pass."
- No headphones? Stays silent. Put them on? It talks.

---

## Quick Start

```bash
# 1. Install TTS engine
pip3 install edge-tts

# 2. Clone
git clone https://github.com/iflorit/claude-voice-summary.git
cd claude-voice-summary

# 3. Copy skills (directory format required by Claude Code)
cp -r skills/vsm-summary <your-project>/.claude/skills/
cp -r skills/vsm <your-project>/.claude/skills/

# 4. Copy script
mkdir -p <your-project>/tooling/scripts
cp scripts/voice-summary.sh <your-project>/tooling/scripts/
chmod +x <your-project>/tooling/scripts/voice-summary.sh

# 5. Copy notification hook (auto-speaks on events)
cp scripts/voice-notification-hook.sh <your-project>/tooling/scripts/
chmod +x <your-project>/tooling/scripts/voice-notification-hook.sh

# 6. Enable (add to .claude/settings.local.json)
# "env": { "VOICE_SUMMARY": "headphones", "VOICE_DEPTH": "detail" }
# "hooks": { "Notification": [{"hooks": [{"type": "command", "command": "<your-project>/tooling/scripts/voice-notification-hook.sh", "async": true}]}] }
```

### Skills installed

| Skill | Command | What it does |
|-------|---------|--------------|
| `vsm-summary` | `/vsm-summary` | Narrate the last agent result or session milestone |
| `vsm` | `/vsm headphones detail` | Change voice mode and depth at runtime |

### Hooks

| Hook | Event | What it does |
|------|-------|--------------|
| `voice-notification-hook.sh` | Notification / Stop | Auto-speaks notifications (agent completions, task results) |

---

## Settings

### Output mode (`VOICE_SUMMARY`)

| Value | When it plays |
|-------|---------------|
| `off` | Never (default) |
| `headphones` | Only when headphones are connected |
| `all` | Speakers or headphones |

### Depth level (`VOICE_DEPTH`)

| Value | What you hear |
|-------|---------------|
| `info` | Facts only: "Done. 1354 tests, 0 failures." |
| `detail` | Facts + context: "Fixed 25 tests. Root cause was regex boundary. No regressions." **(default)** |
| `explain` | Full explanation: architecture decisions, why patterns were chosen, trade-offs |

```json
{
  "env": {
    "VOICE_SUMMARY": "headphones",
    "VOICE_DEPTH": "detail"
  }
}
```

Change at runtime: `/vsm headphones detail` or `/vsm all explain`

---

## What gets narrated

Not just results -- everything relevant:

- **Agent completions**: what it did, result, impact
- **Session milestones**: build passed, tests ran, PR created
- **Questions**: when Claude needs a decision from you
- **Decisions**: confirming what was chosen
- **Errors/blockers**: what failed and next steps

Questions are always narrated regardless of depth -- you need to hear them.

---

## Usage

### `/vsm-summary` skill

Type `/vsm-summary` in Claude Code. It:

1. Identifies what just happened (agent, milestone, question)
2. Generates narration at your chosen depth
3. Plays it through your headphones

### Programmatic

```bash
echo "The orchestrator now uses a Strategy pattern with 4 providers" > /tmp/summary.txt
./tooling/scripts/voice-summary.sh /tmp/summary.txt es
```

Languages: `es` (Spanish, default), `en` (English).

---

## Voices

Neural voices from Microsoft Edge -- natural, expressive, fast.

| Language | Voice | Quality |
|----------|-------|---------|
| Spanish | `es-ES-AlvaroNeural` | Natural male, Castilian Spanish |
| English | `en-GB-RyanNeural` | Natural male, British English |

Falls back to macOS `say` (Monica/Daniel) if edge-tts is unavailable.

### Add more voices

```bash
# In voice-summary.sh, add:
VOICE_FR="fr-FR-HenriNeural"
VOICE_DE="de-DE-ConradNeural"
VOICE_JA="ja-JP-KeitaNeural"
```

Browse all voices: `edge-tts --list-voices`

---

## How It Works

```
Claude Code agent completes
         |
    /vsm-summary skill
         |
    Classify: Business | Architecture | Implementation | QA
         |
    Generate 3-5 sentence summary
         |
    Write to /tmp/claude-voice-summaries/latest_summary.txt
         |
    voice-summary.sh
         |
    Check $VOICE_SUMMARY mode
         |
    +---------+------------+
    |         |            |
   off    headphones     all
    |         |            |
  exit   check audio    proceed
          output          |
            |         generate
         headphones?     edge-tts
          / \            |
        no   yes      afplay
        |     |
      exit  generate
            edge-tts
               |
            afplay
```

---

## Requirements

- **macOS** (headphone detection via `system_profiler`, playback via `afplay`)
- **Python 3** + `edge-tts` (`pip3 install edge-tts`)
- **Claude Code CLI**

> Linux/Windows support: PRs welcome. Replace `system_profiler` with `pactl` (Linux) or `Get-AudioDevice` (Windows).

---

## License

MIT

