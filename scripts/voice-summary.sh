#!/bin/bash
# voice-summary.sh — Generate and play voice summary of agent output
# Usage: ./voice-summary.sh <text_file> [language]
# Requires: edge-tts + macOS `afplay`
#
# VOICE_SUMMARY env var controls behavior:
#   off        — never play (default)
#   headphones — only play when headphones/AirPods are connected
#   all        — always play (headphones or speaker)

set -euo pipefail

TEXT_FILE="${1:-}"
LANG="${2:-es}"
VOICE_ES="es-ES-AlvaroNeural"
VOICE_EN="en-GB-RyanNeural"
OUTPUT_DIR="/tmp/claude-voice-summaries"
MODE="${VOICE_SUMMARY:-off}"

# Check headphones connected
has_headphones() {
    system_profiler SPAudioDataType 2>/dev/null | grep -qi "airpod\|headphone\|bluetooth.*output"
}

# Main gate
case "$MODE" in
    off)
        echo "[voice-summary] Disabled (VOICE_SUMMARY=off)"
        exit 0
        ;;
    headphones)
        if ! has_headphones; then
            echo "[voice-summary] Skipped — no headphones detected (VOICE_SUMMARY=headphones)"
            exit 0
        fi
        ;;
    all)
        ;; # always play
    *)
        echo "[voice-summary] Unknown mode '$MODE' — use off|headphones|all"
        exit 0
        ;;
esac

if [ -z "$TEXT_FILE" ] || [ ! -f "$TEXT_FILE" ]; then
    echo "[voice-summary] No text file provided or file not found: $TEXT_FILE"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
AUDIO_FILE="$OUTPUT_DIR/summary_${TIMESTAMP}.mp3"

# Select voice
if [ "$LANG" = "es" ]; then
    VOICE="$VOICE_ES"
else
    VOICE="$VOICE_EN"
fi

TEXT=$(cat "$TEXT_FILE")
if [ -z "$TEXT" ]; then
    echo "[voice-summary] Empty text, skipping"
    exit 0
fi

echo "[voice-summary] Generating audio with edge-tts voice '$VOICE'..."
edge-tts --voice "$VOICE" --text "$TEXT" --write-media "$AUDIO_FILE" 2>/dev/null

if [ ! -f "$AUDIO_FILE" ]; then
    echo "[voice-summary] edge-tts failed, falling back to macOS say"
    AUDIO_FILE="$OUTPUT_DIR/summary_${TIMESTAMP}.aiff"
    if [ "$LANG" = "es" ]; then
        say -v "Mónica" -o "$AUDIO_FILE" "$TEXT"
    else
        say -v "Daniel" -o "$AUDIO_FILE" "$TEXT"
    fi
fi

echo "[voice-summary] Playing summary..."
afplay "$AUDIO_FILE" &
PLAY_PID=$!

# Clean up after playback
wait $PLAY_PID 2>/dev/null
rm -f "$AUDIO_FILE"
echo "[voice-summary] Done"
