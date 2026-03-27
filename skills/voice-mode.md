---
name: voice-mode
description: Change voice output and depth — /voice-mode [off|headphones|all] [info|detail|explain]
user_invocable: true
args: mode depth
---

# Voice Mode

Change voice summary settings at runtime.

## Usage

```
/voice-mode headphones          # change output mode only
/voice-mode all explain         # change both output and depth
/voice-mode off                 # disable voice
/voice-mode                     # show current settings
```

## Arguments

### Output mode (first arg)
| Value | Behavior |
|-------|----------|
| `off` | Never plays audio |
| `headphones` | Only when headphones are connected |
| `all` | Always plays |

### Depth level (second arg, optional)
| Value | What you hear |
|-------|---------------|
| `info` | Facts only: "Done. 0 failures." |
| `detail` | Facts + context (default) |
| `explain` | Full reasoning, architecture decisions, how code works |

## Instructions

1. Parse args: first = mode, second = depth (optional)
2. If no args, show current `$VOICE_SUMMARY` and `$VOICE_DEPTH` values
3. Update `.claude/settings.local.json`:
   - `"VOICE_SUMMARY": "<mode>"` if mode provided
   - `"VOICE_DEPTH": "<depth>"` if depth provided
4. Confirm the change
5. If mode is `headphones` or `all`, play confirmation:
   ```bash
   echo "Modo de voz: <mode>. Nivel de detalle: <depth>." > /tmp/claude-voice-summaries/mode_change.txt
   ./tooling/scripts/voice-summary.sh /tmp/claude-voice-summaries/mode_change.txt es
   ```
