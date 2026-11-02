#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

usage() {
  cat <<'USAGE'
Usage: ./install.sh [A|D|I|S]

  A  Full setup: Dock (if needed), install flow, then SSH key (default)
  D  Clear Dock now
  I  Run the package and configuration install flow
  S  Create or show the default SSH key
USAGE
}

if (( $# > 1 )); then
  usage >&2
  exit 2
fi

mode="${1:-}"
if [[ -z "$mode" ]]; then
  if [[ -t 0 ]]; then
    printf 'Choose setup: [A]ll, [D]ock, [I]nstall, [S]SH (A): '
    read -r mode || mode=A
    mode="${mode:-A}"
  else
    mode=A
  fi
fi

clear_dock() {
  "$DOTFILES_DIR/scripts/clear-dock.sh"
}

dock_is_clear() {
  local apps others recents
  apps="$(defaults read com.apple.dock persistent-apps 2>/dev/null || true)"
  others="$(defaults read com.apple.dock persistent-others 2>/dev/null || true)"
  recents="$(defaults read com.apple.dock show-recents 2>/dev/null || printf '1')"
  if printf '%s' "$apps" | grep -Eq 'bundle-identifier|file-label'; then
    return 1
  fi
  if printf '%s' "$others" | grep -Eq 'file-label|directory-tile'; then
    return 1
  fi
  [[ "$recents" == '0' ]]
}

clear_dock_if_needed() {
  if dock_is_clear; then
    echo "Dock is already clear; skipping. Choose D to run Dock cleanup again."
  else
    clear_dock
  fi
}

run_install() {
  echo "🚀 Starting Dev OS setup..."

  # Homebrew
  if ! command -v brew >/dev/null 2>&1; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  if [ -f /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -f /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  else
    echo "Homebrew installation did not create a brew executable." >&2
    exit 1
  fi

  # Packages and apps
  brew bundle --file "$DOTFILES_DIR/Brewfile"

  # Directories and config files
  mkdir -p "$HOME/.config" "$HOME/.config/ghostty" "$HOME/.nvm" "$HOME/.local/bin"
  cp -f "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
  cp -f "$DOTFILES_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
  cp -f "$DOTFILES_DIR/ghostty/config" "$HOME/.config/ghostty/config"

  # Apply the Nerd Font to every macOS Terminal profile.
  if ! osascript "$DOTFILES_DIR/scripts/configure-terminal-font.applescript"; then
    echo "Could not update Terminal profiles automatically. Set the font in Terminal Settings > Profiles > Text."
  fi

  # Cursor CLI
  if [ -d "/Applications/Cursor.app" ]; then
    ln -sf \
      /Applications/Cursor.app/Contents/Resources/app/bin/code \
      "$HOME/.local/bin/cursor" || true
  fi
  export PATH="$HOME/.local/bin:$PATH"

  # NVM + Node LTS
  export NVM_DIR="$HOME/.nvm"
  local nvm_script
  nvm_script="$(brew --prefix nvm)/nvm.sh"
  if [[ ! -s "$nvm_script" ]]; then
    echo "nvm was not installed. Check the Homebrew bundle step above." >&2
    exit 1
  fi
  # shellcheck disable=SC1090
  . "$nvm_script"
  nvm install --lts
  nvm alias default 'lts/*'
  nvm use default

  # Corepack is no longer bundled with Node.js 25 and later.
  if ! command -v corepack >/dev/null 2>&1; then
    npm install --global corepack@latest
  fi
  corepack enable
  corepack install --global pnpm@latest
  pnpm --version

  echo "✅ Package, Node, Corepack, pnpm, and config setup complete."
}

run_ssh() {
  "$DOTFILES_DIR/scripts/create-ssh-key.sh"
}

mode="$(printf '%s' "$mode" | tr '[:upper:]' '[:lower:]')"
case "$mode" in
  a|all)
    clear_dock_if_needed
    run_install
    # Installing or opening apps can add Dock icons; clear them once more.
    clear_dock_if_needed
    run_ssh
    ;;
  d|dock)
    clear_dock
    ;;
  i|install)
    run_install
    ;;
  s|ssh)
    run_ssh
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac
