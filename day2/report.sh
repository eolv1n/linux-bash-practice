#!/usr/bin/env bash
set -euo pipefail

mkdir -p day2

OUT="day2/report.md"
: > "$OUT"

{
  echo "# Day 2 — Text Processing Report"
  echo
  echo "Generated at: $(date -Iseconds)"
  echo

  echo "## Users and Shells (first 10)"
  echo
  echo '```'
  cut -d: -f1,7 /etc/passwd | head | column -t -s: || true
  echo '```'
  echo

  echo "## Services sample (first 10 lines, first 20 chars)"
  echo
  echo '```'
  if [ -r /etc/services ]; then
    cut -c1-20 /etc/services | head
  else
    echo "/etc/services not found"
  fi
  echo '```'
  echo

  echo "## /etc/hosts (no comments/blank)"
  echo
  echo '```'
  if [ -r /etc/hosts ]; then
    sed -E '/^\s*#/d; /^\s*$/d' /etc/hosts | head -n 20
  else
    echo "/etc/hosts not found"
  fi
  echo '```'
  echo

  echo "## Uppercase demo via tr"
  echo
  echo '```'
  echo "hello world via TR" | tr '[:lower:]' '[:upper:]'
  echo '```'
  echo

  echo "## awk: swap fields (shell user)"
  echo
  echo '```'
  awk -F: '{print $7, $1}' /etc/passwd | head | column -t || true
  echo '```'
  echo

  echo "## Top 10 shells from /etc/passwd"
  echo
  echo '```'
  cut -d: -f7 /etc/passwd \
    | sort \
    | uniq -c \
    | sort -nr \
    | head -n 10
  echo '```'
} | tee "$OUT"

echo "✅ Report generated: $OUT"
