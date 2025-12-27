#!/usr/bin/env bash
set -euo pipefail

# ========= CONFIG =========
GITHUB_USER="ifahadone"
SSH_PORT=22                # change if router forwards e.g. 2222 -> 22
SSH_USER="$(whoami)"
# ==========================

SSH_DIR="$HOME/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

echo "▶ Syncing SSH keys from GitHub user: ${GITHUB_USER}"
echo

# 1. Ensure ~/.ssh exists with correct permissions
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

# 2. Fetch SSH keys from GitHub (authoritative source)
KEYS=$(curl -fsSL "https://github.com/${GITHUB_USER}.keys")

if [[ -z "$KEYS" ]]; then
  echo "❌ No SSH keys found for GitHub user: ${GITHUB_USER}"
  exit 1
fi

# 3. OVERRIDE authorized_keys (idempotent, no duplicates)
echo "$KEYS" | sort -u > "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

echo "✅ authorized_keys synced from GitHub (override mode)"
echo

# 4. Detect public IP (best effort)
PUBLIC_IP=$(curl -fsSL https://ifconfig.me || true)
[[ -z "$PUBLIC_IP" ]] && PUBLIC_IP="<PUBLIC_IP_NOT_DETECTED>"

# 5. Print login instructions
echo "🔑 LOGIN FROM OUTSIDE NETWORK"
echo "--------------------------------"
echo "Public IP : $PUBLIC_IP"
echo "SSH Port  : $SSH_PORT"
echo "User      : $SSH_USER"
echo
echo "👉 SSH command:"
echo "ssh -p ${SSH_PORT} ${SSH_USER}@${PUBLIC_IP}"
echo
echo "👉 With explicit key:"
echo "ssh -i ~/.ssh/id_ed25519 -p ${SSH_PORT} ${SSH_USER}@${PUBLIC_IP}"
echo
