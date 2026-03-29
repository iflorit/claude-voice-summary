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
QUEUE_DIR="$OUTPUT_DIR/queue"
LOCK_FILE="$OUTPUT_DIR/.playback.lock"
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

# Generate audio
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

# Queue-based playback — no overlap
mkdir -p "$QUEUE_DIR"
QUEUE_FILE="$QUEUE_DIR/$(date +%s%N)_$(basename "$AUDIO_FILE")"
mv "$AUDIO_FILE" "$QUEUE_FILE"

# Try to acquire lock (become the player)
if (set -o noclobber; echo $$ > "$LOCK_FILE") 2>/dev/null; then
    # We are the player — drain the queue
    trap 'rm -f "$LOCK_FILE"' EXIT
    while true; do
        NEXT=$(ls -1 "$QUEUE_DIR"/* 2>/dev/null | head -1)
        [ -z "$NEXT" ] && break
        echo "[voice-summary] Playing: $(basename "$NEXT")"
        afplay "$NEXT" 2>/dev/null
        rm -f "$NEXT"
    done
    echo "[voice-summary] Queue empty. Done."
else
    # Another instance is already playing — file is queued, it will be picked up
    echo "[voice-summary] Queued (another playback in progress)"
fi
