#!/usr/bin/env bash
set -euo pipefail

key="$HOME/.ssh/id_ed25519"
comment=personal_mac

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is intended for macOS." >&2
  exit 1
fi

if [[ -e "$key" || -e "$key.pub" ]]; then
  if [[ -f "$key" && -f "$key.pub" ]]; then
    existing_comment=$(ssh-keygen -lf "$key.pub" | awk '{print $3}')
    if [[ "$existing_comment" == "$comment" ]]; then
      echo "Default SSH key already exists with comment '$comment'; leaving it unchanged."
      printf '\nAdd this public key to GitHub:\n'
      cat "$key.pub"
      exit 0
    fi
  fi
  echo "Refusing to overwrite an existing default SSH key: $key" >&2
  exit 1
fi

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
ssh-keygen -t ed25519 -a 64 -C "$comment" -f "$key"
chmod 600 "$key"

printf '\nAdd this public key to GitHub:\n'
cat "$key.pub"
printf '\nPrivate key: %s\n' "$key"
