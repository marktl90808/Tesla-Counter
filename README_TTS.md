README_TTS.md

MacOS Text-to-Speech helper for the Tesla Counter project

Overview

This repository includes a small bash helper script `scripts/read_chat.sh` that uses the macOS `say` utility to either speak text aloud or write audio files.

Files added

- `scripts/read_chat.sh` - CLI wrapper around `say` with options to speak text, read from a file, and write audio output.
- `scripts/sample_text.txt` - Example chat text you can use for testing.

Usage

Speak a short text aloud:

  ./scripts/read_chat.sh -t "Hello from Tesla Counter"

Read a text file aloud:

  ./scripts/read_chat.sh -f scripts/sample_text.txt

Save spoken audio to a file:

  ./scripts/read_chat.sh -t "Save this text" -o /tmp/chat.aiff

Save from a file to an m4a file:

  ./scripts/read_chat.sh -f scripts/sample_text.txt -o /tmp/chat.m4a

Options

- `-t TEXT`    : Text to speak (mutually exclusive with -f)
- `-f FILE`    : Path to a text file to read (mutually exclusive with -t)
- `-o OUTPUT`  : Path to write audio output. If omitted, the script will speak aloud.
- `-v VOICE`   : Voice identifier for `say` (default: system voice)
- `-r RATE`    : Speaking rate words-per-minute
- `-h`         : Show help

Notes

- The script uses `say` and `afconvert` for audio conversion where appropriate. It writes a temporary AIFF file when producing an output file and then converts or moves to the requested extension.
- If you need MP3 output, the script writes an m4a (AAC) file and renames it; for better MP3 encoding, install `lame` and convert locally.

Examples

  # Speak a sample text file
  ./scripts/read_chat.sh -f scripts/sample_text.txt

  # Save the sample text as m4a
  ./scripts/read_chat.sh -f scripts/sample_text.txt -o /tmp/assistant_chat.m4a

