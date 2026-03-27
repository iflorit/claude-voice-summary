---
name: voice-mode
description: Change voice summary mode — /voice-mode off|headphones|all
user_invocable: true
args: mode
---

# Voice Mode

Change the voice summary mode at runtime.

## Usage

```
/voice-mode off
/voice-mode headphones
/voice-mode all
```

## Instructions

1. Read the argument: `$ARGS` should be one of `off`, `headphones`, `all`
2. If no argument or invalid, show current mode and available options
3. Update the env var in `.claude/settings.local.json`:
   - Read the file
   - Change `"VOICE_SUMMARY": "<new_mode>"` in the `env` object
   - Write the file
4. Confirm the change to the user
5. If changing TO `headphones` or `all`, play a test message:
   ```bash
   echo "Modo de voz cambiado a <mode>" > /tmp/claude-voice-summaries/mode_change.txt
   ./tooling/scripts/voice-summary.sh /tmp/claude-voice-summaries/mode_change.txt es
   ```
