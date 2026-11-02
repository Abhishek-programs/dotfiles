#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This script is for macOS." >&2
  exit 1
fi

domain=com.apple.dock
backup="$HOME/Library/Preferences/com.apple.dock.backup-$(date +%Y%m%d-%H%M%S).plist"

defaults export "$domain" "$backup"
defaults write "$domain" persistent-apps -array
defaults write "$domain" persistent-others -array
defaults write "$domain" show-recents -bool false
if ! killall Dock; then
  echo "Dock preferences are cleared; macOS will apply them after Dock reloads."
fi

echo "Cleared pinned Dock apps, folders, and suggested/recent items."
echo "Previous Dock preferences backed up to: $backup"
