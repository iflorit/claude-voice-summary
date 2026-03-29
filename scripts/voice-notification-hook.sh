#!/bin/bash
# Notification hook: speaks Claude Code notifications via voice-summary.sh
# Triggers on agent completions, task completions, and other notifications.
set -euo pipefail

# Check voice mode
VOICE_MODE="${VOICE_SUMMARY:-off}"
[[ "$VOICE_MODE" == "off" ]] && exit 0

INPUT=$(cat)

# Extract notification message
MESSAGE=$(echo "$INPUT" | jq -r '.message // .notification // .summary // ""' 2>/dev/null)
[[ -z "$MESSAGE" ]] && exit 0

# Write to temp file and speak
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SUMMARY_FILE="/tmp/claude-voice-summaries/notification.txt"
mkdir -p /tmp/claude-voice-summaries

echo "$MESSAGE" > "$SUMMARY_FILE"
"$SCRIPT_DIR/voice-summary.sh" "$SUMMARY_FILE" es &

exit 0
