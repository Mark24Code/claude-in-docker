#!/bin/bash

# 跨平台初始化脚本
# 兼容 Linux, macOS 和 Windows (WSL/Git Bash)

set -e

echo "=== Initializing devcontainer configuration ==="

# 检测操作系统并设置路径
if [ -n "$USERPROFILE" ]; then
    # Windows (WSL 或 Git Bash)
    USER_HOME="$USERPROFILE"
    USER_HOME=$(echo "$USER_HOME" | sed 's|\\|/|g')  # 转换反斜杠为正斜杠
else
    # Linux 或 macOS
    USER_HOME="$HOME"
fi

# ===== SSH 配置检查 =====
SSH_DIR="$USER_HOME/.ssh"
echo "Checking SSH directory: $SSH_DIR"

if [ ! -d "$SSH_DIR" ]; then
    echo "Creating SSH directory: $SSH_DIR"
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
    echo "Warning: SSH directory was empty. Please add your SSH keys to $SSH_DIR"
else
    echo "SSH directory exists: ✓"

    # 检查是否有 SSH 密钥
    if ls "$SSH_DIR"/id_* 1> /dev/null 2>&1; then
        echo "SSH keys found: ✓"
    else
        echo "Warning: No SSH keys found in $SSH_DIR"
        echo "Please generate SSH keys using: ssh-keygen -t ed25519 -C 'your_email@example.com'"
    fi
fi

# ===== Zsh 配置检查 =====
ZSHRC_FILE="$USER_HOME/.zshrc"
echo "Checking Zsh configuration: $ZSHRC_FILE"

if [ -f "$ZSHRC_FILE" ]; then
    echo "Host .zshrc found: ✓ (will be used in container)"
else
    echo "No host .zshrc found: Container default will be used"
fi

# ===== Git 配置检查 =====
GITCONFIG_FILE="$USER_HOME/.gitconfig"
echo "Checking Git configuration: $GITCONFIG_FILE"

if [ -f "$GITCONFIG_FILE" ]; then
    echo "Git config found: ✓"
else
    echo "Warning: No .gitconfig found"
    echo "Please configure git: git config --global user.name 'Your Name'"
    echo "                      git config --global user.email 'your@email.com'"
fi

echo "=== Initialization completed ==="
