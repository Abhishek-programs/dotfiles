#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Bootstrapping Dev OS..."

# ---------------------------
# Ensure Xcode tools
# ---------------------------
xcode-select -p >/dev/null 2>&1 || xcode-select --install || true

# ---------------------------
# Ensure git exists (rare case)
# ---------------------------
if ! command -v git >/dev/null 2>&1; then
  echo "Installing git via xcode tools..."
fi

# ---------------------------
# Clone dotfiles
# ---------------------------
DOTFILES="$HOME/.dotfiles"

if [ -d "$DOTFILES" ]; then
  echo "📁 Dotfiles already exist, updating..."
  cd "$DOTFILES"
  git pull
else
  echo "📥 Cloning dotfiles..."
  git clone https://github.com/Abhishek-programs/dotfiles.git "$DOTFILES"
  cd "$DOTFILES"
fi

# ---------------------------
# Run installer
# ---------------------------
chmod +x install.sh
./install.sh

# ---------------------------
# Final shell reload
# ---------------------------
echo ""
echo "✅ Bootstrap complete"
echo "👉 Run: gh auth login"
echo "👉 Then: exec zsh"
