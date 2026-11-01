#!/usr/bin/env bash

root="$(cd "$(dirname "$0")/.." && pwd)"
icon="$root/plugins/aido/.claude-plugin/icon.png"
min_side=512
max_side=2048
max_bytes=$((2 * 1024 * 1024))

if [ ! -f "$icon" ]; then
  echo "FAIL - no icon at $icon"
  exit 1
fi

dimensions="$(file -b "$icon" | sed -nE 's/^PNG image data, ([0-9]+) x ([0-9]+),.*/\1 \2/p')"
read -r width height <<<"$dimensions"
bytes="$(stat -c %s "$icon")"

if [ -z "$dimensions" ] || [ "$width" != "$height" ] || [ "$width" -lt "$min_side" ] \
  || [ "$width" -gt "$max_side" ] || [ "$bytes" -ge "$max_bytes" ]; then
  echo "FAIL - icon is not a square PNG of $min_side to $max_side px under 2 MB: ${dimensions:-not a PNG}, $bytes bytes"
  exit 1
fi
echo "ok   - icon is a square PNG of $width px, $bytes bytes"
