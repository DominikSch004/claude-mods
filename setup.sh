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

# Refresh marketplace $1 if it's known, else add it from repo $2.
ensure_marketplace() {
  if claude plugin marketplace list 2>/dev/null | grep -q "❯ $1\$"; then
    retry claude plugin marketplace update "$1"
  else
    retry claude plugin marketplace add "$2" --scope user
  fi
}

ensure_marketplace "$MARKETPLACE" "$MARKETPLACE_REPO"

for mod in "${MODS[@]}"; do
  retry claude plugin install "${mod}@${MARKETPLACE}" --scope user
done

# ECC (everything-claude-code) comes from its own marketplace. Claude Code
# doesn't install its npm packages, and its hooks crash without them, so do
# that here. Plugins can't ship rules either, so copy the rule packs; a pack
# that's already there is left alone.
ECC_REPO="https://github.com/affaan-m/everything-claude-code.git"
ECC_RULES=(common typescript)

ensure_marketplace ecc "$ECC_REPO"
retry claude plugin install ecc@ecc --scope user

ecc_dir=$(ls -d ~/.claude/plugins/cache/ecc/ecc/*/ | sort -V | tail -1)
if command -v npm >/dev/null; then
  [ -f "${ecc_dir}node_modules/.package-lock.json" ] ||
    (cd "$ecc_dir" && retry npm ci --omit=dev --ignore-scripts --no-audit --no-fund)
else
  echo "ECC's hooks need Node.js and npm; install them, then re-run this script." >&2
fi
mkdir -p ~/.claude/rules/ecc
for pack in "${ECC_RULES[@]}"; do
  [ -d ~/.claude/rules/ecc/"$pack" ] || cp -R "${ecc_dir}rules/$pack" ~/.claude/rules/ecc/
done

echo
echo "Done. Restart Claude Code (or run /reload-plugins) to load the mods and ECC."
