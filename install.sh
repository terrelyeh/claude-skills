#!/usr/bin/env bash
#
# One-line installer for EnGenius shareable Claude Code skills.
#   curl -fsSL https://raw.githubusercontent.com/terrelyeh/claude-skills/main/install.sh | bash
#
# Copies every skill under skills/ into ~/.claude/skills/ (overwriting same-named
# ones). Re-run any time to update. No secrets are installed — API keys are read
# from your environment (see README / 安裝說明.md).

set -euo pipefail

REPO_URL="https://github.com/terrelyeh/claude-skills.git"
DEST="$HOME/.claude/skills"

echo "📦 Installing Claude skills from claude-skills…"

if ! command -v git >/dev/null 2>&1; then
  echo "❌ git not found. Install it first:  xcode-select --install"
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

git clone --depth 1 "$REPO_URL" "$TMP" >/dev/null 2>&1 || {
  echo "❌ Could not clone $REPO_URL — check your network / repo access."
  exit 1
}

mkdir -p "$DEST"
count=0
for d in "$TMP"/skills/*/; do
  [ -d "$d" ] || continue
  name="$(basename "$d")"
  rm -rf "$DEST/$name"
  cp -R "$d" "$DEST/$name"
  echo "  ✅ $name"
  count=$((count + 1))
done

echo ""
echo "Done — installed $count skill(s) into $DEST"
echo ""
echo "▶ Next: set your EnGenius API key (one time), then restart Claude Code:"
echo "    echo 'export SPECHUB_API_KEY=\"sk_live_xxx\"' >> ~/.zshrc"
echo "    source ~/.zshrc"
echo ""
echo "Then in any Claude Code session:  /engenius-kb 哪些 AP 支援 WiFi 7?"
