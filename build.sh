#!/usr/bin/env bash
# Rebuilds index.html (the deployable page) from wine-guide.html (the source fragment).
#
# wine-guide.html starts directly with <title>/<link>/<style> (no <!DOCTYPE>, <html>,
# <head> or <body>) because that's the format the Claude Artifact tool publishes from
# -- it wraps the fragment with those tags itself at publish time. For a standalone
# static-site deploy (GitHub + Vercel) we need a complete document, so this script
# finds the closing </style> tag and splits the fragment there: everything before it
# goes inside <head>, everything after goes inside <body>.
#
# Usage: ./build.sh   (run from the repo root)

set -euo pipefail
cd "$(dirname "$0")"

SRC="wine-guide.html"
OUT="index.html"

split_line=$(grep -n '^</style>' "$SRC" | head -1 | cut -d: -f1)
if [ -z "$split_line" ]; then
  echo "error: could not find a line containing exactly </style> in $SRC" >&2
  exit 1
fi

{
  echo '<!DOCTYPE html>'
  echo '<html lang="ko">'
  echo '<head>'
  echo '<meta charset="UTF-8">'
  echo '<meta name="viewport" content="width=device-width, initial-scale=1">'
  sed -n "1,${split_line}p" "$SRC"
  echo '</head>'
  echo '<body>'
  sed -n "$((split_line + 1)),\$p" "$SRC"
  echo '</body>'
  echo '</html>'
} > "$OUT"

echo "built $OUT from $SRC ($(wc -l < "$OUT") lines)"
