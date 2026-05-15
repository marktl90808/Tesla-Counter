#!/usr/bin/env bash
# read_chat.sh - simple macOS TTS helper
# Usage:
#   ./read_chat.sh -t "Text to speak"
#   ./read_chat.sh -f /path/to/textfile.txt
#   ./read_chat.sh -t "Hello" -o /tmp/output.aiff
#   ./read_chat.sh -f scripts/sample_text.txt -o output.m4a

set -euo pipefail

print_usage() {
  cat <<EOF
Usage: $0 [-t text] [-f file] [-o output] [-v voice] [-r rate]

Options:
  -t TEXT    Text to speak (mutually exclusive with -f)
  -f FILE    Path to a text file to read (mutually exclusive with -t)
  -o OUTPUT  Path to write audio output. If omitted, the script will speak aloud.
  -v VOICE   Voice identifier for `say` (default: default system voice)
  -r RATE    Speaking rate words-per-minute (default: system default)
  -h         Show this help message

Examples:
  $0 -t "Hello from Tesla Counter"
  $0 -f scripts/sample_text.txt
  $0 -t "Save this" -o /tmp/chat.aiff
  $0 -f scripts/sample_text.txt -o /tmp/chat.m4a
EOF
}

TEXT=""
FILE=""
OUTPUT=""
VOICE=""
RATE=""

while getopts ":t:f:o:v:r:h" opt; do
  case ${opt} in
    t ) TEXT="$OPTARG" ;;
    f ) FILE="$OPTARG" ;;
    o ) OUTPUT="$OPTARG" ;;
    v ) VOICE="$OPTARG" ;;
    r ) RATE="$OPTARG" ;;
    h ) print_usage; exit 0 ;;
    \? ) echo "Invalid Option: -$OPTARG" 1>&2; print_usage; exit 1 ;;
  esac
done

if [[ -n "$TEXT" && -n "$FILE" ]]; then
  echo "Specify either -t or -f, not both." >&2
  exit 2
fi

if [[ -z "$TEXT" && -z "$FILE" ]]; then
  echo "Either -t or -f is required." >&2
  print_usage
  exit 2
fi

if [[ -n "$FILE" ]]; then
  if [[ ! -f "$FILE" ]]; then
    echo "File not found: $FILE" >&2
    exit 3
  fi
  TEXT_CONTENT=$(cat "$FILE")
else
  TEXT_CONTENT="$TEXT"
fi

SAY_CMD=(say)

if [[ -n "$VOICE" ]]; then
  SAY_CMD+=("-v" "$VOICE")
fi

if [[ -n "$RATE" ]]; then
  SAY_CMD+=("-r" "$RATE")
fi

if [[ -n "$OUTPUT" ]]; then
  # macOS `say` supports -o for file output; extension influences format
  SAY_CMD+=("-o" "$OUTPUT" "--data-format=AIFF")
  # When writing to compressed formats like m4a, use `afconvert` afterwards
  tmp_aiff="$OUTPUT.aiff.tmp"
  # prefer to write to tmp aiff then convert if necessary
  SAY_CMD=("say")
  if [[ -n "$VOICE" ]]; then
    SAY_CMD+=("-v" "$VOICE")
  fi
  if [[ -n "$RATE" ]]; then
    SAY_CMD+=("-r" "$RATE")
  fi
  SAY_CMD+=("-o" "$tmp_aiff" "$TEXT_CONTENT")
  # run
  "${SAY_CMD[@]}"
  # If output already is .aiff or .aif, move; if .m4a or .mp3, convert
  ext="${OUTPUT##*.}"
  case "$ext" in
    aiff|aif)
      mv "$tmp_aiff" "$OUTPUT"
      ;;
    m4a)
      # convert using afconvert to m4af
      afconvert -f m4af -d aac -b 128000 "$tmp_aiff" "$OUTPUT"
      rm -f "$tmp_aiff"
      ;;
    wav)
      afconvert -f WAVE -d LEI16 "$tmp_aiff" "$OUTPUT"
      rm -f "$tmp_aiff"
      ;;
    mp3)
      # macOS lacks a native mp3 encoder cli; try afconvert to m4a as fallback
      afconvert -f m4af -d aac -b 128000 "$tmp_aiff" "${OUTPUT}.m4a"
      mv "${OUTPUT}.m4a" "$OUTPUT"
      rm -f "$tmp_aiff"
      ;;
    *)
      # default to aiff
      mv "$tmp_aiff" "$OUTPUT"
      ;;
  esac
else
  # speak aloud
  SAY_CMD+=("$TEXT_CONTENT")
  "${SAY_CMD[@]}"
fi
