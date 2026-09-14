#!/usr/bin/env bash
set -euo pipefail

# story-listen.sh — turn one chapter into spoken audio (Microsoft Edge TTS).
# Usage: story-listen.sh <ch-XX> [--voice <voice>]
# Run from inside a story folder. Writes _listens/<ref>.mp3 and prints its path.

ref="${1:?usage: story-listen.sh <ch-XX> [--voice <voice>]}"
voice="en-US-GuyNeural"
if [[ "${2:-}" == "--voice" && -n "${3:-}" ]]; then
  voice="$3"
fi

# Locate the chapter file: Chapters/ folder if present, else the story root.
dir="."
[[ -d "Chapters" ]] && dir="Chapters"

chapter="$(find "$dir" -maxdepth 1 -type f -name "${ref}.md" -print | head -n1)"
if [[ -z "$chapter" ]]; then
  chapter="$(find "$dir" -maxdepth 1 -type f -name "${ref}*" -print | head -n1)"
fi
if [[ -z "$chapter" ]]; then
  echo "error: no chapter matching '${ref}'" >&2
  exit 1
fi

mkdir -p _listens
out="_listens/${ref}.mp3"

plain="$(mktemp)"
trap 'rm -f "$plain"' EXIT
# --wrap=none is load-bearing. Pandoc otherwise hard-wraps at 72 columns, and
# edge-tts passes newlines straight into the SSML, where the voice renders each
# one as a pause. Without it the narration stops at random mid-sentence words.
pandoc "$chapter" -t plain --wrap=none -o "$plain"

edge-tts --file "$plain" --voice "$voice" --write-media "$out"

echo "$out"
