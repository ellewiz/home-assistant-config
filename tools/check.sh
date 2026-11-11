#!/bin/sh
# Guardrails for the PUBLIC home-assistant-config repo.
# Run from anywhere inside the repo:  sh tools/check.sh
# Runs as the git pre-commit hook (on the HA host) and in CI (.github/workflows/ci.yml).
# Exit 1 if any check fails. NOTICE lines never fail the run.
# Skip once in an emergency: git commit --no-verify

cd "$(git rev-parse --show-toplevel)" || exit 2

FAILS=0
fail() { echo "FAIL: $1"; FAILS=$((FAILS + 1)); }
note() { echo "NOTICE: $1"; }
ok()   { echo "ok: $1"; }

BASELINE=tools/ratchet-baseline.txt
base() { sed -n "s/^$1=//p" "$BASELINE" 2>/dev/null | head -n 1; }

# ---------------------------------------------------------------- 1. private files
# The repo is public. Health data, backups, secrets and runtime state must never be tracked.
# git ls-files includes anything already staged with git add, so this also works pre-commit.
PRIVATE_RE='^(packages/health_|health_data/|_reports/|scripts/dose_|secrets\.yaml$|ip_bans\.yaml$|automation_notes_archive\.md$|tools/private-terms\.txt$)|\.db(-shm|-wal)?$|\.bak'
BAD=$(git ls-files | grep -E "$PRIVATE_RE")
if [ -n "$BAD" ]; then
  echo "$BAD" | sed 's/^/  /'
  fail "private or backup files are tracked (listed above). Fix: git rm --cached <file> and make sure .gitignore covers it. If it was ever pushed, history still holds it and needs a filter-repo scrub."
else
  ok "no private or backup files tracked"
fi

# ---------------------------------------------------------------- 2. secret-shaped strings
# Prints file names only, never the matching text, so a CI log can't leak the secret.
SECRET_RE='ghp_[A-Za-z0-9]{20,}|github_pat_[A-Za-z0-9_]{20,}|-----BEGIN [A-Z ]*PRIVATE KEY-----|eyJ[A-Za-z0-9_-]{30,}\.[A-Za-z0-9_-]{10,}|AIza[0-9A-Za-z_-]{35}|hc-ping\.com/[0-9a-f]{8}-[0-9a-f]{4}-'
HITS=$(git ls-files | grep -vE '^tools/check\.sh$|\.(png|jpe?g|gif|ico|woff2?|ttf|zip|gz|mp3|wav|svg)$' | while IFS= read -r f; do
  [ -f "$f" ] && grep -aqE "$SECRET_RE" "$f" && echo "$f"
done)
if [ -n "$HITS" ]; then
  echo "$HITS" | sed 's/^/  /'
  fail "secret-shaped strings (GitHub token, private key, long-lived access token, Google API key or Healthchecks ping URL) in the files above. Move the value to secrets.yaml and reference it with !secret."
else
  ok "no secret-shaped strings in tracked files"
fi

# ---------------------------------------------------------------- 2b. coordinates
# A latitude= / longitude= value with 3+ decimals pins a location to ~100 m or better.
# Request URLs that need the home coordinates live in secrets.yaml and are referenced with !secret.
# Prints file names only.
COORD_RE='(latitude|longitude)[=:][[:space:]]*-?[0-9]{1,3}\.[0-9]{3,}'
HITS=$(git ls-files | grep -vE '^tools/check\.sh$|\.(png|jpe?g|gif|ico|woff2?|ttf|zip|gz|mp3|wav|svg)$' | while IFS= read -r f; do
  [ -f "$f" ] && grep -aqiE "$COORD_RE" "$f" && echo "$f"
done)
if [ -n "$HITS" ]; then
  echo "$HITS" | sed 's/^/  /'
  fail "precise coordinates in the files above. Move the whole URL or value to secrets.yaml and reference it with !secret."
else
  ok "no precise coordinates in tracked files"
fi

# ---------------------------------------------------------------- 2c. private terms
# tools/private-terms.txt is git-ignored (the list of terms is itself private): one extended
# regex per line, matched case-insensitively, # for comments. It exists on the HA host, so the
# pre-commit hook enforces it. CI has no copy and skips this check.
# Prints file names only, never the matching text.
TERMS=tools/private-terms.txt
if [ -f "$TERMS" ]; then
  PATS=$(mktemp)
  grep -vE '^[[:space:]]*(#|$)' "$TERMS" > "$PATS"
  if [ -s "$PATS" ]; then
    HITS=$(git ls-files | grep -vE '^tools/check\.sh$|\.(png|jpe?g|gif|ico|woff2?|ttf|zip|gz|mp3|wav|svg)$' | while IFS= read -r f; do
      [ -f "$f" ] && grep -aqiE -f "$PATS" "$f" && echo "$f"
    done)
    if [ -n "$HITS" ]; then
      echo "$HITS" | sed 's/^/  /'
      fail "private terms (see tools/private-terms.txt) in the tracked files above. Move that config to a git-ignored packages/health_*.yaml file."
    else
      ok "no private terms in tracked files"
    fi
  else
    note "tools/private-terms.txt has no patterns. Private-terms check skipped."
  fi
  rm -f "$PATS"
else
  note "tools/private-terms.txt not present (expected in CI). Private-terms check skipped."
fi

# ---------------------------------------------------------------- 3. scripts.yaml
# Scripts load from the scripts/ directory. Nothing includes scripts.yaml, so a script written
# there validates, reads back fine, and never appears as an entity.
if [ -f scripts.yaml ]; then
  CONTENT=$(grep -vE '^[[:space:]]*(#|$|---[[:space:]]*$)' scripts.yaml | tr -d ' \t')
  if [ -n "$CONTENT" ] && [ "$CONTENT" != '{}' ] && [ "$CONTENT" != '[]' ]; then
    fail "scripts.yaml has content, but nothing includes it (scripts load from scripts/, one file per script). Move each script to scripts/<script_id>.yaml, empty scripts.yaml, then call script.reload."
  else
    ok "scripts.yaml is empty"
  fi
else
  ok "no scripts.yaml"
fi

# ---------------------------------------------------------------- 4. ratchets on automations.yaml
# Counts may go down, never up. HA pads automations.yaml with NUL bytes, so strip them first.
AUTO=automations.yaml
if [ -f "$AUTO" ]; then
  CLEAN=$(mktemp)
  tr -d '\000' < "$AUTO" > "$CLEAN"

  ratchet() { # name, regex, hint
    now=$(grep -cE "$2" "$CLEAN")
    was=$(base "$1")
    if [ -z "$was" ]; then
      fail "no baseline for $1 in $BASELINE"
    elif [ "$now" -gt "$was" ]; then
      fail "$1 rose from $was to $now. $3"
    elif [ "$now" -lt "$was" ]; then
      note "$1 dropped from $was to $now. Lower it in $BASELINE so it can't creep back."
      ok "$1 ($now, baseline $was)"
    else
      ok "$1 ($now, baseline $was)"
    fi
  }

  ratchet legacy_platform_triggers '^[[:space:]]*(-[[:space:]]+)?platform:' \
    "New automations use the modern keys (triggers: / trigger: state). See automation-style.md section 1."
  ratchet device_id_uses '^[[:space:]]*(-[[:space:]]+)?device_id:' \
    "Prefer entity_id targets. See automation-style.md section 13."

  MAXD=$(base description_max_chars)
  if [ -z "$MAXD" ]; then
    fail "no description_max_chars in $BASELINE"
  else
    LONG=$(awk -v max="$MAXD" '/^[ \t]*description:/ && length($0) > max { printf "%d ", NR }' "$CLEAN")
    if [ -n "$LONG" ]; then
      fail "description: lines over $MAXD characters at line(s) $LONG of $AUTO (numbers are after NUL stripping). Keep descriptions to one line; changelog and rationale go in automation_notes_archive.md. See automation-style.md section 4."
    else
      ok "no description over $MAXD characters"
    fi

    # The check above only sees the first physical line. A folded description spans several
    # lines, so also total each automation's whole description and ratchet how many exceed the cap.
    LONGD=$(awk -v max="$MAXD" '
      function flush() { if (indesc && len > max) n++; indesc = 0; len = 0 }
      /^- / { flush() }
      /^  description:/ { flush(); indesc = 1; s = $0; sub(/^  description:[ \t]*/, "", s); len = length(s); next }
      indesc && /^    / { s = $0; sub(/^[ \t]+/, "", s); len += length(s) + 1; next }
      indesc { flush() }
      END { flush(); print n + 0 }' "$CLEAN")
    WASD=$(base long_descriptions)
    if [ -z "$WASD" ]; then
      fail "no baseline for long_descriptions in $BASELINE"
    elif [ "$LONGD" -gt "$WASD" ]; then
      fail "long_descriptions rose from $WASD to $LONGD. A description (all its lines together) is over $MAXD characters. Keep it short; rationale goes in automation_notes_archive.md. See automation-style.md section 4."
    elif [ "$LONGD" -lt "$WASD" ]; then
      note "long_descriptions dropped from $WASD to $LONGD. Lower it in $BASELINE so it can't creep back."
      ok "long_descriptions ($LONGD, baseline $WASD)"
    else
      ok "long_descriptions ($LONGD, baseline $WASD)"
    fi
  fi
  rm -f "$CLEAN"
fi

echo
if [ "$FAILS" -gt 0 ]; then
  echo "check.sh: $FAILS check(s) failed"
  exit 1
fi
echo "check.sh: all checks passed"
