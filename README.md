# Claude Code Voice Summary

Voice summaries for agent task completions in Claude Code. Reads summaries aloud through your headphones after long agent operations using high-quality neural TTS.

## Features

- Headphone detection (AirPods, Bluetooth, wired) — never plays through speakers unless you want it to
- High-quality neural TTS via [edge-tts](https://github.com/rany2/edge-tts) (Microsoft Edge Neural Voices)
- Fallback to macOS `say` if edge-tts is unavailable
- Spanish and English voice support (easily extensible)
- Skill `/agent-summary` for manual invocation
- Three modes: `off`, `headphones`, `all`

## Installation

### 1. Install TTS engine

```bash
pip3 install edge-tts
```

### 2. Copy to your Claude Code project

```bash
# Skill
cp skills/agent-summary.md <your-project>/.claude/skills/

# Script
mkdir -p <your-project>/tooling/scripts
cp scripts/voice-summary.sh <your-project>/tooling/scripts/
chmod +x <your-project>/tooling/scripts/voice-summary.sh
```

### 3. Configure

Add to your `.claude/settings.local.json`:

```json
{
  "env": {
    "VOICE_SUMMARY": "headphones"
  }
}
```

## Modes

| `VOICE_SUMMARY` | Behavior |
|------------------|----------|
| `off` | Never plays audio (default if unset) |
| `headphones` | Plays only when headphones/AirPods are connected |
| `all` | Always plays (speakers or headphones) |

## Usage

### Manual (via skill)

```
/agent-summary
```

Generates a summary of the last completed agent task and reads it aloud.

### Programmatic (from scripts or hooks)

```bash
echo "Your summary text here" > /tmp/summary.txt
./tooling/scripts/voice-summary.sh /tmp/summary.txt es
```

Second argument is the language: `es` (Spanish, default) or `en` (English).

## Voices

| Language | Voice | Provider |
|----------|-------|----------|
| Spanish (es) | `es-ES-AlvaroNeural` | Microsoft Edge |
| English (en) | `en-GB-RyanNeural` | Microsoft Edge |
| Spanish fallback | `Monica` | macOS `say` |
| English fallback | `Daniel` | macOS `say` |

### Adding more voices

Edit `voice-summary.sh` and add voice variables:

```bash
VOICE_FR="fr-FR-HenriNeural"
VOICE_DE="de-DE-ConradNeural"
```

Full voice list: `edge-tts --list-voices`

## Requirements

- macOS (uses `system_profiler` for headphone detection and `afplay` for playback)
- Python 3 + edge-tts
- Claude Code CLI

## How it works

1. Claude Code completes a long agent task
2. `/agent-summary` skill generates a concise explanation
3. Summary is written to `/tmp/claude-voice-summaries/latest_summary.txt`
4. `voice-summary.sh` checks `$VOICE_SUMMARY` mode
5. If `headphones`: checks `system_profiler SPAudioDataType` for AirPods/Bluetooth
6. Generates audio via `edge-tts` (or `say` fallback)
7. Plays via `afplay` and cleans up

## License

MIT
