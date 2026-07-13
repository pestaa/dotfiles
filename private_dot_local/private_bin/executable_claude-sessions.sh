#!/usr/bin/env bash
# List Claude Code sessions active within the last N hours (default 12),
# as a Markdown table: project (cwd) + last active + started + topic.
#
# Usage:   ~/.claude/sessions.sh [hours]
# Env:     CLAUDE_PROJECTS  override projects dir (default: ~/.claude/projects)
#
# Notes:   Times are shown in UTC, as stored in the session transcripts.
#          A session counts as "active" if its transcript file was modified
#          within the window (its *start* time may be older — see the table).

set -uo pipefail

HOURS="${1:-12}"
DIR="${CLAUDE_PROJECTS:-$HOME/.claude/projects}"

command -v jq >/dev/null 2>&1 || { echo "error: jq is required" >&2; exit 1; }
[ -d "$DIR" ] || { echo "error: no projects dir at $DIR" >&2; exit 1; }

mmin=$(( HOURS * 60 ))
rows=()

while IFS= read -r -d '' f; do
  # all timestamps, one jq pass; skip transcripts with none
  readarray -t ts < <(jq -r 'select(.timestamp != null) | .timestamp' "$f" 2>/dev/null)
  [ "${#ts[@]}" -eq 0 ] && continue
  first_raw="${ts[0]}"
  last_raw="${ts[${#ts[@]}-1]}"

  # project = working dir recorded in the transcript (fallback: encoded dir name)
  proj=$(jq -r 'select(.cwd != null) | .cwd' "$f" 2>/dev/null | head -n1)
  [ -z "$proj" ] && proj=$(basename "$(dirname "$f")")

  # topic = first real user message (skip <tags>, system reminders, caveats)
  topic=$(jq -r '
    select(.type=="user")
    | .message.content as $c
    | if   ($c|type)=="string" then $c
      elif ($c|type)=="array"  then ($c[]? | select(.type=="text") | .text)
      else empty end
  ' "$f" 2>/dev/null \
    | grep -vE '^[[:space:]]*(<|Caveat:)' | head -n1)

  topic=$(printf '%s' "$topic" | tr '\n' ' ')   # single line
  topic=${topic//|/\\|}                          # escape pipes for markdown
  [ "${#topic}" -gt 90 ] && topic="${topic:0:90}…"
  [ -z "$topic" ] && topic="—"

  last_disp="${last_raw:0:10} ${last_raw:11:5}"
  first_disp="${first_raw:0:10} ${first_raw:11:5}"

  rows+=("${last_raw}"$'\t'"${proj}"$'\t'"${last_disp}"$'\t'"${first_disp}"$'\t'"${topic}")
done < <(find "$DIR" -maxdepth 2 -name '*.jsonl' -type f -mmin "-${mmin}" -print0 2>/dev/null)

echo "## Claude sessions active in the last ${HOURS}h  (as of $(date -u '+%Y-%m-%d %H:%M UTC'))"
echo

if [ "${#rows[@]}" -eq 0 ]; then
  echo "_No sessions found._"
  exit 0
fi

echo "| Project | Last active (UTC) | Started (UTC) | Topic |"
echo "|---|---|---|---|"
# sort by last-active descending (ISO timestamps sort lexically)
printf '%s\n' "${rows[@]}" | sort -r | while IFS=$'\t' read -r _key proj last first topic; do
  echo "| ${proj##*/} | ${last} | ${first} | ${topic} |"
done
