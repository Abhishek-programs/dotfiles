#!/usr/bin/env bash
set -euo pipefail

key="$HOME/.ssh/id_ed25519"
key_pub="$key.pub"
comment=personal_mac
ssh_dir="$HOME/.ssh"
config="$ssh_dir/config"
dropin_dir="$ssh_dir/config.d"
dropin="$dropin_dir/github-personal-mac"
include_line="Include ~/.ssh/config.d/github-personal-mac"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is intended for macOS." >&2
  exit 1
fi

mkdir -p "$ssh_dir"
chmod 700 "$ssh_dir"

if [[ -f "$key" && -f "$key_pub" ]]; then
  echo "Using existing default SSH key: $key"
elif [[ -f "$key" && ! -e "$key_pub" ]]; then
  /usr/bin/ssh-keygen -y -f "$key" > "$key_pub"
  chmod 644 "$key_pub"
elif [[ -e "$key" || -e "$key_pub" ]]; then
  echo "The default SSH key path is incomplete; refusing to overwrite it." >&2
  exit 1
else
  if [[ ! -t 0 ]]; then
    echo "Run this step in an interactive Terminal so ssh-keygen can prompt for a passphrase." >&2
    exit 1
  fi
  /usr/bin/ssh-keygen -t ed25519 -a 64 -C "$comment" -f "$key"
  chmod 600 "$key"
fi

actual_comment=$(/usr/bin/ssh-keygen -lf "$key_pub" | awk '{print $3}')
if [[ "$actual_comment" != "$comment" ]]; then
  echo "The existing key comment is '$actual_comment', not '$comment'; leaving the key unchanged." >&2
fi

# OpenSSH config drop-in keeps existing user settings intact and takes priority.
mkdir -p "$dropin_dir"
if /usr/bin/ssh-keygen -y -P '' -f "$key" >/dev/null 2>&1; then
  has_passphrase=0
else
  has_passphrase=1
fi

tmp_dropin="$dropin.tmp.$$"
{
  printf 'Host github.com\n'
  printf '  HostName ssh.github.com\n'
  printf '  Port 443\n'
  printf '  User git\n'
  printf '  AddKeysToAgent yes\n'
  if (( has_passphrase )); then
    printf '  UseKeychain yes\n'
  fi
  printf '  IdentityFile ~/.ssh/id_ed25519\n'
} > "$tmp_dropin"
chmod 600 "$tmp_dropin"
mv "$tmp_dropin" "$dropin"

if [[ ! -e "$config" ]]; then
  printf '%s\n' "$include_line" > "$config"
elif ! grep -Fqx "$include_line" "$config"; then
  tmp_config=$(mktemp "${TMPDIR:-/tmp}/ssh-config.XXXXXX")
  {
    printf '%s\n' "$include_line"
    cat "$config"
  } > "$tmp_config"
  cat "$tmp_config" > "$config"
  rm "$tmp_config"
fi
chmod 600 "$config"

# GitHub's macOS guidance says to omit UseKeychain for an unencrypted key.
if (( ! has_passphrase )); then
  tmp_config=$(mktemp "${TMPDIR:-/tmp}/ssh-config.XXXXXX")
  awk '
    /^[[:space:]]*Host[[:space:]]/ {
      github_host = 0
      for (i = 2; i <= NF; i++) if ($i == "github.com") github_host = 1
    }
    github_host && /^[[:space:]]*UseKeychain[[:space:]]+/ { next }
    { print }
  ' "$config" > "$tmp_config"
  cat "$tmp_config" > "$config"
  rm "$tmp_config"
  chmod 600 "$config"
fi

# Reuse the session agent when available; otherwise start Apple's ssh-agent.
agent_ready=0
agent_state=$(/usr/bin/ssh-add -l 2>&1 || true)
if /usr/bin/ssh-add -l >/dev/null 2>&1 || [[ "$agent_state" == *"The agent has no identities."* ]]; then
  agent_ready=1
else
  if agent_output=$(/usr/bin/ssh-agent -s 2>&1); then
    eval "$agent_output" >/dev/null
    agent_ready=1
  else
    echo "Could not start ssh-agent in this environment: $agent_output" >&2
  fi
fi

fingerprint=$(/usr/bin/ssh-keygen -lf "$key_pub" | awk '{print $2}')
if (( agent_ready )); then
  if /usr/bin/ssh-add -l 2>/dev/null | grep -Fq "$fingerprint"; then
    echo "SSH key is already loaded in the agent."
  elif (( has_passphrase )); then
    if ! /usr/bin/ssh-add --apple-use-keychain "$key"; then
      echo "Could not add the key to ssh-agent. Run /usr/bin/ssh-add --apple-use-keychain ~/.ssh/id_ed25519 in Terminal." >&2
    fi
  elif ! /usr/bin/ssh-add "$key"; then
    echo "Could not add the key to ssh-agent. Run /usr/bin/ssh-add ~/.ssh/id_ed25519 in Terminal." >&2
  fi
else
  echo 'The key and GitHub config are ready, but ssh-agent is unavailable here. In Terminal run: eval "$(/usr/bin/ssh-agent -s)" && /usr/bin/ssh-add ~/.ssh/id_ed25519' >&2
fi

printf '\nAdd this public key to GitHub:\n'
cat "$key_pub"
printf '\nSSH config: %s\n' "$config"
