# Container Default Zsh Configuration
# This file is used when host machine doesn't have a .zshrc file

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="robbyrussell"

# Plugins
plugins=(git z)

source $ZSH/oh-my-zsh.sh

# ===== Environment Setup =====

# Go
export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Ruby (rbenv)
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# ===== Load workspace .env file =====
if [ -f /workspace/.devcontainer/.env ]; then
  set -a
  source /workspace/.devcontainer/.env
  set +a
fi

# ===== Custom Aliases =====
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gs='git status'
alias gp='git pull'
alias gps='git push'
alias gco='git checkout'
alias gcm='git commit -m'
alias gd='git diff'
alias gl='git log --oneline --graph --decorate'

# ===== History Configuration =====
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# ===== Prompt Configuration =====
# Show git branch in prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'
setopt PROMPT_SUBST
PROMPT='%F{green}%n@%m%f:%F{blue}%~%f%F{red}${vcs_info_msg_0_}%f$ '

# ===== Auto-completion =====
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ===== Welcome Message =====
echo "🐳 Container Environment Ready"
echo "📦 Development tools: Python $(python --version 2>&1 | cut -d' ' -f2), Node $(node --version), Go $(go version | cut -d' ' -f3), Ruby $(ruby --version | cut -d' ' -f2)"
