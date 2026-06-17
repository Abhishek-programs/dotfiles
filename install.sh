#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Starting Dev OS setup..."

# ---------------------------
# Homebrew
# ---------------------------
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# ---------------------------
# Brew install
# ---------------------------
brew bundle --file Brewfile || true

# ---------------------------
# Directories
# ---------------------------
mkdir -p ~/.config ~/.config/ghostty ~/.nvm ~/.local/bin

# ---------------------------
# Configs
# ---------------------------
cp -f zsh/.zshrc ~/.zshrc
cp -f starship/starship.toml ~/.config/starship.toml
cp -f ghostty/config ~/.config/ghostty/config

# ---------------------------
# Cursor CLI
# ---------------------------
if [ -d "/Applications/Cursor.app" ]; then
  ln -sf \
    /Applications/Cursor.app/Contents/Resources/app/bin/code \
    ~/.local/bin/cursor || true
fi

export PATH="$HOME/.local/bin:$PATH"

# ---------------------------
# fzf
# ---------------------------
BREW_PREFIX=$(brew --prefix)

if [ -d "$BREW_PREFIX/opt/fzf" ]; then
  "$BREW_PREFIX/opt/fzf/install" --all --no-update-rc || true
fi

# ---------------------------
# NVM + Node
# ---------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"

if ! command -v node >/dev/null 2>&1; then
  nvm install --lts
  nvm alias default lts/*
fi

# ---------------------------
# Corepack + pnpm
# ---------------------------
corepack enable || true
corepack prepare pnpm@latest --activate || true

# ---------------------------
# Done
# ---------------------------
echo ""
echo "✅ Setup complete"
echo ""
echo "👉 Next step:"
echo "   gh auth login"
echo "   exec zsh"
