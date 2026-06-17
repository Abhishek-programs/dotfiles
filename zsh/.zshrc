
# ---------------------------
# Homebrew
# ---------------------------
eval "$(/opt/homebrew/bin/brew shellenv)"

# PATH (Cursor CLI)
export PATH="$HOME/.local/bin:$PATH"

# ---------------------------
# Completion system
# ---------------------------
autoload -Uz compinit
compinit

# Case-insensitive autocomplete
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# ---------------------------
# Shell behavior
# ---------------------------
setopt AUTO_CD
setopt CORRECT
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS

# ---------------------------
# NVM
# ---------------------------
export NVM_DIR="$HOME/.nvm"
[ -s "$(brew --prefix nvm)/nvm.sh" ] && . "$(brew --prefix nvm)/nvm.sh"

# ---------------------------
# Starship
# ---------------------------
eval "$(starship init zsh)"

# ---------------------------
# Zoxide
# ---------------------------
eval "$(zoxide init zsh --cmd cd)"

# ---------------------------
# FZF
# ---------------------------
eval "$(fzf --zsh)"

# ---------------------------
# eza (ALWAYS icons)
# ---------------------------
alias ls="eza --icons"
alias ll="eza -la --icons"
alias lt="eza --tree --icons"

# ---------------------------
# bat
# ---------------------------
alias cat="bat"

# ---------------------------
# git
# ---------------------------
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"

# ---------------------------
# gh
# ---------------------------
alias pr="gh pr view --web"
alias prs="gh pr status"

# ---------------------------
# navigation
# ---------------------------
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

mkcd() {
  mkdir -p "$1" && cd "$1"
}
