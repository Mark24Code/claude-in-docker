# 开发环境配置说明

本 devcontainer 配置已支持跨平台（Linux/Mac/Windows）使用宿主机的开发配置。

## 自动挂载的配置文件

devcontainer 会自动将宿主机的以下文件/目录挂载到容器中：

- `~/.ssh` → `/home/vscode/.ssh` （SSH 密钥和配置）
- `~/.gitconfig` → `/home/vscode/.gitconfig` （Git 全局配置）
- `~/.zshrc` → `/home/vscode/.zshrc.host` （Zsh 配置，可选）

## Zsh 配置策略

容器使用智能配置加载策略：

### 1. 优先使用宿主机配置
如果宿主机存在 `~/.zshrc`，容器会使用它，并自动添加容器特定的环境变量（开发工具路径等）。

**优点**：
- 保持熟悉的 shell 环境
- 别名、函数、prompt 配置都会生效
- 无需重复配置

### 2. 回退到容器默认配置
如果宿主机没有 `~/.zshrc`，容器会使用预配置的默认配置，包含：
- Oh My Zsh 框架
- 常用插件（git, z）
- 开发工具路径配置
- 实用的 git 别名
- 美观的提示符

### 3. 配置文件说明

```
~/.zshrc                          # 主加载器（自动生成）
~/.zshrc.host                     # 宿主机配置（如果存在）
~/.zshrc.container                # 容器默认配置
~/.zshrc.container.additions      # 容器专用补充（PATH等）
```

加载顺序：
```bash
if [ -f ~/.zshrc.host ]; then
  source ~/.zshrc.host
  source ~/.zshrc.container.additions  # 添加容器环境变量
else
  source ~/.zshrc.container  # 完整的默认配置
fi
```

## 使用前提

### 1. 确保宿主机已配置 SSH 密钥

#### Linux/Mac:
```bash
# 检查是否已有 SSH 密钥
ls -la ~/.ssh/

# 如果没有，生成新密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 将公钥添加到 GitHub/GitLab
cat ~/.ssh/id_ed25519.pub
```

#### Windows:
```powershell
# 在 PowerShell 或 Git Bash 中执行
# 检查是否已有 SSH 密钥
ls $env:USERPROFILE\.ssh\

# 如果没有，生成新密钥
ssh-keygen -t ed25519 -C "your_email@example.com"

# 将公钥添加到 GitHub/GitLab
cat $env:USERPROFILE\.ssh\id_ed25519.pub
```

### 2. 启动 SSH Agent（可选，推荐）

#### Linux/Mac:
```bash
# 启动 ssh-agent
eval "$(ssh-agent -s)"

# 添加密钥
ssh-add ~/.ssh/id_ed25519
```

#### Windows (PowerShell):
```powershell
# 启动 ssh-agent 服务
Start-Service ssh-agent

# 添加密钥
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

### 3. 配置 Git（如果还没有）

```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```

## 验证配置

进入 devcontainer 后，执行以下命令验证：

```bash
# 检查 SSH 密钥是否挂载成功
ls -la ~/.ssh/

# 检查 Git 配置
git config --list

# 检查当前使用的 Zsh 配置
echo "Using config: $([ -f ~/.zshrc.host ] && echo 'Host' || echo 'Container default')"

# 查看 PATH 环境变量（确认开发工具路径）
echo $PATH

# 测试 SSH 连接到 GitHub
ssh -T git@github.com

# 测试 SSH 连接到 GitLab
ssh -T git@gitlab.com
```

## 自定义容器配置

### 方式 1: 修改宿主机 .zshrc（推荐）
直接在宿主机的 `~/.zshrc` 中添加配置，容器会自动使用。

### 方式 2: 修改容器补充配置
如果只想在容器中生效，编辑：
```bash
.devcontainer/container.additions.zshrc
```

### 方式 3: 修改容器默认配置
如果宿主机没有 .zshrc，可以修改：
```bash
.devcontainer/default.zshrc
```

## 常见问题

### Q: 为什么我的宿主机 aliases 在容器中不生效？

检查以下几点：
1. 确认宿主机有 `~/.zshrc` 文件
2. 在容器中运行：`cat ~/.zshrc.host` 查看是否正确挂载
3. 重新加载配置：`source ~/.zshrc`

### Q: 容器中的开发工具（Node/Python/Go）找不到

这通常意味着 PATH 没有正确设置。解决方法：

1. 如果使用宿主机配置，确保 `.zshrc.container.additions` 被加载：
```bash
# 在容器中检查
grep -q "container.additions" ~/.zshrc && echo "Additions enabled" || echo "Not enabled"
```

2. 手动添加到宿主机 `~/.zshrc`：
```bash
# 在宿主机的 ~/.zshrc 中添加
export PATH="$HOME/.pyenv/bin:$HOME/.rbenv/bin:$HOME/.nvm/versions/node/v24.12.0/bin:/usr/local/go/bin:$PATH"
```

### Q: 想要不同的 Zsh 主题或插件

**使用宿主机配置时**：
在宿主机 `~/.zshrc` 中修改即可。

**使用容器默认配置时**：
编辑 `.devcontainer/default.zshrc`，修改：
```bash
ZSH_THEME="agnoster"  # 或其他主题
plugins=(git z docker kubectl)  # 添加更多插件
```

重建容器生效：
```bash
# VS Code 命令面板
Dev Containers: Rebuild Container
```

### Q: SSH 密钥权限错误

如果遇到 "permissions are too open" 错误，容器会在启动时自动修正权限：

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```

### Q: Windows 下路径问题

devcontainer 配置使用了 `${localEnv:HOME}${localEnv:USERPROFILE}` 来兼容不同系统：
- Linux/Mac: 使用 `$HOME`
- Windows: 使用 `$USERPROFILE`

### Q: Git 提交时需要输入密码

这通常意味着：
1. SSH 密钥没有正确挂载
2. 远程仓库使用的是 HTTPS 而不是 SSH

解决方法：
```bash
# 检查当前远程仓库 URL
git remote -v

# 如果是 HTTPS，改为 SSH
git remote set-url origin git@github.com:username/repo.git
```

### Q: SSH Agent 转发

容器会自动尝试使用宿主机的 SSH Agent。如果需要手动配置：

```bash
# 在容器中检查 SSH Agent
ssh-add -l

# 如果需要，手动添加密钥
ssh-add ~/.ssh/id_ed25519
```

## 安全建议

1. **不要在容器中生成新的 SSH 密钥** - 使用宿主机的密钥
2. **确保宿主机的 SSH 密钥有密码保护**
3. **定期轮换 SSH 密钥**
4. **使用 ED25519 算法** - 比 RSA 更安全且更快

## 支持的平台

- ✅ Linux (所有发行版)
- ✅ macOS (Intel/Apple Silicon)
- ✅ Windows 10/11 (WSL2)
- ✅ Windows (Git Bash/PowerShell)
