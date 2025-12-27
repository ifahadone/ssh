#!/usr/bin/env bash
set -euo pipefail

# ===== CONFIG =====
GITHUB_USER="ifahadone"
SSH_PORT=22
SSH_USER="$(whoami)" # auto-detect user
HOST_IP="$(hostname -I | awk '{print $1}')" # best guess
# ==================

SSH_DIR="$HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

echo "▶ Installing SSH keys from GitHub user: $GITHUB_USER"
echo

# 1. Ensure .ssh exists
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 2. Fetch keys
KEYS=$(curl -fsSL "https://github.com/${GITHUB_USER}.keys")

if [[ -z "$KEYS" ]]; then
  echo "❌ No SSH keys found for GitHub user: $GITHUB_USER"
  exit 1
fi

# 3. Install keys (idempotent)
echo "$KEYS" | sort -u > "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

echo "✅ SSH keys installed successfully"
echo

# 4. Print login command
echo "🔑 Login using:"
echo
echo "ssh -p ${SSH_PORT} ${SSH_USER}@${HOST_IP}"
echo
echo "📌 If using a custom key:"
echo "ssh -i ~/.ssh/id_ed25519 -p ${SSH_PORT} ${SSH_USER}@${HOST_IP}"
echo
