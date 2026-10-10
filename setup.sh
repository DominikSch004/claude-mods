#!/usr/bin/env bash
# Installs my Claude Code mods on this machine. Safe to re-run: it refreshes
# the marketplace and installs whatever is missing.
#
#   curl -fsSL https://raw.githubusercontent.com/DominikSch004/claude-mods/main/setup.sh | bash
set -euo pipefail

MARKETPLACE_REPO="${CLAUDE_MODS_SOURCE:-https://github.com/DominikSch004/claude-mods.git}"  # override with a local path to test
MARKETPLACE="dominik-mods"
MODS=(savvy-progress savvy-flow filetree skins blast-radius)

command -v claude >/dev/null || { echo "claude is not on PATH; install Claude Code first." >&2; exit 1; }

# A clone from GitHub can drop mid-transfer; try a few times.
retry() {
  local attempt
  for attempt in 1 2 3; do
    "$@" && return 0
    [ "$attempt" -lt 3 ] && { echo "Retrying in 5s: $*" >&2; sleep 5; }
  done
  return 1
}

if claude plugin marketplace list 2>/dev/null | grep -q "❯ ${MARKETPLACE}\$"; then
  retry claude plugin marketplace update "$MARKETPLACE"
else
  retry claude plugin marketplace add "$MARKETPLACE_REPO" --scope user
fi

for mod in "${MODS[@]}"; do
  retry claude plugin install "${mod}@${MARKETPLACE}" --scope user
done

echo
echo "Done. Restart Claude Code (or run /reload-plugins) to load the mods."
