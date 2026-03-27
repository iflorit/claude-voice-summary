# Claude Code Voice Summary

Voice summaries for agent task completions in Claude Code. Reads summaries aloud through your headphones after long agent operations.

## Features
- Detects headphone connection (AirPods, Bluetooth, wired)
- High-quality neural TTS via edge-tts (Microsoft Edge)
- Spanish and English voice support
- Skill `/agent-summary` for manual invocation
- Environment variable `VOICE_SUMMARY_ENABLED` for always-on mode

## Installation

1. Install edge-tts:
```bash
pip3 install edge-tts
```

2. Copy files to your Claude Code project:
```bash
cp skills/agent-summary.md <your-project>/.claude/skills/
cp scripts/voice-summary.sh <your-project>/tooling/scripts/
chmod +x <your-project>/tooling/scripts/voice-summary.sh
```

3. Enable in settings (`.claude/settings.local.json`):
```json
{
  "env": {
    "VOICE_SUMMARY_ENABLED": "true"
  }
}
```

## Usage

### Manual
```
/agent-summary
```

### Automatic (via env var)
Set `VOICE_SUMMARY_ENABLED=true` and summaries play automatically after agent completions.

## Voices
- Spanish: `es-ES-AlvaroNeural` (default)
- English: `en-GB-RyanNeural`

## Requirements
- macOS (uses `afplay` for playback)
- Python 3 + edge-tts
- Headphones connected OR `VOICE_SUMMARY_ENABLED=true`
