#!/usr/bin/env sh

if [ -z "$1" ]; then
  echo "Need a file to generate symbol file"
  exit 1
fi

of=$(basename "$1" | rev | sed 's/^.*\.//' | rev)
outfile="${of}.sym"

[ -f "$outfile" ] && rm "$outfile"

objcopy --only-keep-debug "$1" "$outfile"

objcopy --add-gnu-debuglink="$outfile" "$1"
