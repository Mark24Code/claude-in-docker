# DevContainer 配置说明

## 快速开始

本 devcontainer 已配置为自动使用宿主机的开发环境配置，支持 **Linux、Mac 和 Windows** 系统。

### 自动挂载的配置

容器启动时会自动挂载以下宿主机配置：

| 宿主机位置 | 容器位置 | 说明 |
|-----------|---------|------|
| `~/.ssh` | `/home/vscode/.ssh` | SSH 密钥（用于 Git） |
| `~/.gitconfig` | `/home/vscode/.gitconfig` | Git 全局配置 |
| `~/.zshrc` | `/home/vscode/.zshrc.host` | Zsh 配置（可选） |

### Zsh 配置策略

✅ **有宿主机 .zshrc**：使用你的配置 + 自动添加容器环境变量
✅ **无宿主机 .zshrc**：使用精心配置的容器默认配置

### 内置工具

- **语言**: Python 3.13.1, Node.js 24.12.0, Go 1.23.4, Ruby 3.4.1
- **Shell**: Zsh + Oh My Zsh
- **版本控制**: Git, Tig
- **AI**: Claude Code

## 验证配置

进入容器后运行测试脚本：

```bash
~/.local/bin/test-config.sh
```

或手动验证：

```bash
# 查看使用哪个配置
[ -f ~/.zshrc.host ] && echo "Using host config" || echo "Using container default"

# 测试 SSH 连接
ssh -T git@github.com

# 测试 Git
git config --list
```

## 详细文档

完整配置说明和故障排除，请查看：
📚 **[ENVIRONMENT-SETUP.md](./ENVIRONMENT-SETUP.md)**

## 目录结构

```
.devcontainer/
├── devcontainer.json              # 主配置文件
├── Dockerfile                     # 容器镜像定义
├── init-command.sh                # 启动前初始化脚本
├── init-claude.sh                 # Claude Code 初始化
├── default.zshrc                  # 容器默认 Zsh 配置
├── container.additions.zshrc      # 容器专用环境变量
├── test-config.sh                 # 配置验证脚本
├── ENVIRONMENT-SETUP.md           # 详细文档
└── README.md                      # 本文件
```

## 常见问题

### Q: Git 提交时提示需要密码？

使用 SSH URL 而不是 HTTPS：
```bash
git remote set-url origin git@github.com:username/repo.git
```

### Q: 开发工具找不到？

在容器中运行：
```bash
echo $PATH
source ~/.zshrc
```

### Q: 想自定义配置？

**推荐**：修改宿主机 `~/.zshrc`（自动生效）
**备选**：修改 `.devcontainer/default.zshrc`（需重建容器）

## 支持平台

| 平台 | 状态 | 说明 |
|------|------|------|
| 🐧 Linux | ✅ | 完全支持 |
| 🍎 macOS | ✅ | Intel 和 Apple Silicon |
| 🪟 Windows | ✅ | WSL2 / Git Bash |

---

🚀 **开箱即用** - 启动容器后即可开始开发，无需额外配置！
