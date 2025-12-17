#!/bin/bash

# 配置验证测试脚本
# 在容器启动后运行此脚本来验证所有配置

echo "======================================"
echo "  Development Environment Test"
echo "======================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试函数
test_item() {
    local name=$1
    local command=$2

    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC} $name"
        return 0
    else
        echo -e "${RED}✗${NC} $name"
        return 1
    fi
}

# 测试配置文件
echo "📁 Configuration Files:"
test_item "SSH directory mounted" "[ -d ~/.ssh ]"
test_item "SSH keys present" "ls ~/.ssh/id_* 2>/dev/null"
test_item "Git config mounted" "[ -f ~/.gitconfig ]"
test_item "Zsh config loaded" "[ -f ~/.zshrc ]"

if [ -f ~/.zshrc.host ]; then
    echo -e "   ${YELLOW}→${NC} Using host .zshrc configuration"
else
    echo -e "   ${YELLOW}→${NC} Using container default .zshrc"
fi
echo ""

# 测试开发工具
echo "🛠  Development Tools:"
test_item "Git installed" "command -v git"
test_item "Zsh installed" "command -v zsh"
test_item "Python available" "command -v python"
test_item "Node.js available" "command -v node"
test_item "Go available" "command -v go"
test_item "Ruby available" "command -v ruby"
test_item "Claude Code installed" "command -v claude"
echo ""

# 显示版本信息
echo "📦 Tool Versions:"
echo -e "   Python: $(python --version 2>&1 | cut -d' ' -f2)"
echo -e "   Node.js: $(node --version)"
echo -e "   npm: $(npm --version)"
echo -e "   Go: $(go version | cut -d' ' -f3)"
echo -e "   Ruby: $(ruby --version | cut -d' ' -f2)"
echo -e "   Git: $(git --version | cut -d' ' -f3)"
echo ""

# 测试 Git 配置
echo "⚙️  Git Configuration:"
if git config user.name > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} User name: $(git config user.name)"
else
    echo -e "   ${RED}✗${NC} User name not configured"
fi

if git config user.email > /dev/null 2>&1; then
    echo -e "   ${GREEN}✓${NC} User email: $(git config user.email)"
else
    echo -e "   ${RED}✗${NC} User email not configured"
fi
echo ""

# 测试 SSH
echo "🔐 SSH Configuration:"
if [ -d ~/.ssh ]; then
    SSH_KEYS=$(ls ~/.ssh/id_* 2>/dev/null | wc -l)
    if [ "$SSH_KEYS" -gt 0 ]; then
        echo -e "   ${GREEN}✓${NC} Found $SSH_KEYS SSH key(s)"
        ls ~/.ssh/id_* 2>/dev/null | while read key; do
            echo -e "     - $(basename $key)"
        done
    else
        echo -e "   ${YELLOW}⚠${NC} No SSH keys found"
        echo -e "     Generate with: ssh-keygen -t ed25519 -C 'your@email.com'"
    fi

    # 检查权限
    SSH_PERMS=$(stat -c %a ~/.ssh 2>/dev/null || stat -f %A ~/.ssh)
    if [ "$SSH_PERMS" = "700" ]; then
        echo -e "   ${GREEN}✓${NC} SSH directory permissions correct (700)"
    else
        echo -e "   ${YELLOW}⚠${NC} SSH directory permissions: $SSH_PERMS (should be 700)"
    fi
else
    echo -e "   ${RED}✗${NC} SSH directory not found"
fi
echo ""

# 测试环境变量
echo "🌍 Environment Variables:"
test_item "ANTHROPIC_AUTH_TOKEN set" "[ ! -z \"\$ANTHROPIC_AUTH_TOKEN\" ]"
test_item "PATH includes Go" "echo \$PATH | grep -q go"
test_item "PATH includes Python" "echo \$PATH | grep -q pyenv"
test_item "PATH includes Node" "echo \$PATH | grep -q nvm"
test_item "PATH includes Ruby" "echo \$PATH | grep -q rbenv"
echo ""

# 总结
echo "======================================"
echo "  Test completed!"
echo "======================================"
echo ""
echo "💡 Useful commands:"
echo "   - Test GitHub SSH: ssh -T git@github.com"
echo "   - Test GitLab SSH: ssh -T git@gitlab.com"
echo "   - Reload shell config: source ~/.zshrc"
echo "   - Check which config: [ -f ~/.zshrc.host ] && echo 'Host' || echo 'Container'"
