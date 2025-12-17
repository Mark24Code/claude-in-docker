# Container-Specific Additions to Host .zshrc
# This file is sourced AFTER host .zshrc if it exists
# Add container-only configurations here without modifying host config

# ===== Container Environment Info =====
# Ensure development tools are in PATH
export GOPATH="$HOME/go"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# Node.js (nvm)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" 2>/dev/null

# Python (pyenv)
export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" 2>/dev/null

# Ruby (rbenv)
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)" 2>/dev/null

# ===== Load workspace .env file =====
if [ -f /workspace/.devcontainer/.env ]; then
  set -a
  source /workspace/.devcontainer/.env
  set +a
fi

# ===== Container-specific aliases =====
# Only add if not already defined
alias docker-ls 2>/dev/null || alias docker-ls='docker ps -a'
alias workspace 2>/dev/null || alias workspace='cd /workspace'
