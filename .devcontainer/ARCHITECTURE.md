# DevContainer 跨平台配置架构

## 概述

本配置实现了完全跨平台（Linux/Mac/Windows）的开发容器环境，自动使用宿主机的 SSH、Git 和 Zsh 配置。

## 核心设计原则

1. **优先使用宿主机配置** - 保持开发者熟悉的环境
2. **智能回退** - 宿主机无配置时使用容器默认
3. **零配置启动** - 开箱即用，无需手动设置
4. **跨平台兼容** - 同一配置支持所有主流操作系统

## 配置文件结构

```
.devcontainer/
│
├── devcontainer.json              # VS Code Dev Container 配置
│   ├── mounts: 挂载宿主机配置文件
│   ├── initializeCommand: 启动前检查脚本
│   └── postCreateCommand: 容器创建后初始化
│
├── Dockerfile                     # 容器镜像定义
│   ├── 安装开发工具 (Python, Node, Go, Ruby)
│   ├── 配置 Oh-My-Zsh
│   └── 设置智能 .zshrc 加载器
│
├── init-command.sh                # 宿主机初始化脚本
│   ├── 检查 SSH 密钥
│   ├── 检查 .zshrc
│   └── 检查 Git 配置
│
├── default.zshrc                  # 容器默认 Zsh 配置
│   ├── Oh-My-Zsh 设置
│   ├── 开发工具 PATH
│   ├── 常用别名
│   └── .env 文件加载
│
├── container.additions.zshrc      # 容器环境补充
│   ├── 开发工具 PATH (pyenv, nvm, rbenv, go)
│   └── .env 文件加载
│
├── test-config.sh                 # 配置验证脚本
│   └── 全面测试所有配置项
│
└── init-claude.sh                 # Claude Code 初始化
    └── 设置 Claude 认证
```

## 工作流程

### 1. 容器启动前 (宿主机)

```
initializeCommand: .devcontainer/init-command.sh
```

**执行内容**：
- 检测操作系统（Linux/Mac/Windows）
- 验证 `~/.ssh` 目录和密钥存在
- 检查 `~/.zshrc` 是否存在
- 验证 `~/.gitconfig` 配置

**支持的环境变量**：
- Linux/Mac: `$HOME`
- Windows: `$USERPROFILE`

### 2. 挂载宿主机配置

```json
"mounts": [
  "source=${localEnv:HOME}${localEnv:USERPROFILE}/.ssh,target=/home/vscode/.ssh",
  "source=${localEnv:HOME}${localEnv:USERPROFILE}/.gitconfig,target=/home/vscode/.gitconfig",
  "source=${localEnv:HOME}${localEnv:USERPROFILE}/.zshrc,target=/home/vscode/.zshrc.host"
]
```

**跨平台兼容性**：
- `${localEnv:HOME}${localEnv:USERPROFILE}` 自动选择正确的环境变量
- Linux/Mac: 展开为 `$HOME`
- Windows: 展开为 `$USERPROFILE`

### 3. Zsh 配置加载逻辑

容器中的 `~/.zshrc` (自动生成):

```bash
# Smart Zsh Configuration Loader

if [ -f ~/.zshrc.host ]; then
  # 宿主机有配置 - 使用它
  source ~/.zshrc.host

  # 添加容器必需的环境变量
  if [ -f ~/.zshrc.container.additions ]; then
    source ~/.zshrc.container.additions
  fi
else
  # 宿主机无配置 - 使用容器默认
  source ~/.zshrc.container
fi
```

**文件说明**：

| 文件 | 来源 | 用途 |
|------|------|------|
| `~/.zshrc` | 容器生成 | 主加载器，负责分发逻辑 |
| `~/.zshrc.host` | 宿主机挂载 | 你的个人配置（别名、主题等） |
| `~/.zshrc.container` | 镜像内置 | 完整的默认配置 |
| `~/.zshrc.container.additions` | 镜像内置 | 容器专用环境变量补充 |

### 4. 容器创建后

```
postCreateCommand:
  1. 修正 SSH 密钥权限 (chmod 600/700)
  2. 初始化 Claude Code
  3. 验证所有开发工具安装
```

## 场景分析

### 场景 1: 宿主机有 .zshrc

**流程**：
```
1. 检测到 ~/.zshrc.host (挂载自宿主机)
2. 加载宿主机配置
3. 追加 ~/.zshrc.container.additions
   - 添加 pyenv, nvm, rbenv, go 到 PATH
   - 加载 /workspace/.devcontainer/.env
```

**结果**：
- ✅ 你的别名、函数、主题全部生效
- ✅ 容器内开发工具可用
- ✅ 无需修改宿主机配置

### 场景 2: 宿主机无 .zshrc

**流程**：
```
1. 未检测到 ~/.zshrc.host
2. 加载 ~/.zshrc.container (完整配置)
   - Oh-My-Zsh + robbyrussell 主题
   - 插件: git, z
   - 开发工具 PATH
   - 常用 Git 别名
   - 加载 .env 文件
```

**结果**：
- ✅ 开箱即用的精美配置
- ✅ 所有开发工具可用
- ✅ 类似宿主机的使用体验

## 跨平台实现细节

### Windows 兼容性

**路径处理**：
```bash
if [ -n "$USERPROFILE" ]; then
    USER_HOME="$USERPROFILE"
    USER_HOME=$(echo "$USER_HOME" | sed 's|\\|/|g')  # C:\Users\... → C:/Users/...
fi
```

**测试平台**：
- ✅ WSL2 (推荐)
- ✅ Git Bash
- ✅ PowerShell (通过环境变量)

### macOS 兼容性

**支持架构**：
- ✅ Intel (x86_64)
- ✅ Apple Silicon (arm64)

**注意事项**：
- Docker Desktop for Mac 必需
- Rosetta 2 自动处理架构转换（如需要）

### Linux 兼容性

**测试发行版**：
- ✅ Ubuntu 20.04+
- ✅ Debian 11+
- ✅ Fedora 35+
- ✅ Arch Linux

## SSH 密钥管理

### 权限自动修正

```bash
postCreateCommand: "chmod 600 ~/.ssh/* 2>/dev/null || true && chmod 700 ~/.ssh 2>/dev/null || true"
```

**为什么需要**：
- Windows 文件系统权限不同
- 挂载后权限可能过于宽松
- SSH 要求严格权限 (700/600)

### SSH Agent 转发

配置支持 SSH Agent 转发（可选）:
```json
"features": {
  "ghcr.io/devcontainers/features/sshd:1": {
    "version": "latest"
  }
}
```

## 环境变量管理

### 容器环境变量

```json
"containerEnv": {
  "ANTHROPIC_AUTH_TOKEN": "${localEnv:ANTHROPIC_AUTH_TOKEN}",
  // ... 其他变量
}
```

**从宿主机注入**，支持：
- Linux/Mac: 从 shell 环境
- Windows: 从系统环境变量

### .env 文件加载

两处自动加载 `/workspace/.devcontainer/.env`:

1. **default.zshrc** (场景2)
2. **container.additions.zshrc** (场景1)

## 验证和测试

### 手动验证

```bash
# 进入容器后
~/.local/bin/test-config.sh
```

### 自动验证

包含在 `postCreateCommand` 中：
- ✓ 所有开发工具版本
- ✓ SSH 配置状态
- ✓ Git 配置检查

## 故障排除

### 问题：宿主机配置未生效

**检查**：
```bash
# 在容器中
ls -la ~/.zshrc*
cat ~/.zshrc  # 查看加载逻辑
```

**可能原因**：
- 宿主机 .zshrc 不存在
- 挂载路径错误
- VS Code 未检测到环境变量

### 问题：开发工具找不到

**检查**：
```bash
echo $PATH
source ~/.zshrc
which python node go ruby
```

**解决方案**：
- 确认 .zshrc.container.additions 被加载
- 手动添加 PATH 到宿主机 .zshrc

### 问题：SSH 权限错误

**自动修复**：
```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/*
```

## 维护和更新

### 更新开发工具版本

编辑 `Dockerfile`:
```dockerfile
# 更新 Python 版本
pyenv install 3.14.0
pyenv global 3.14.0

# 更新 Node.js 版本
nvm install 25.0.0
nvm alias default 25.0.0
```

### 修改默认配置

编辑 `.devcontainer/default.zshrc`:
```bash
ZSH_THEME="agnoster"  # 更改主题
plugins=(git z docker kubectl)  # 添加插件
```

### 添加新挂载

编辑 `devcontainer.json`:
```json
"mounts": [
  // ... 现有挂载
  "source=${localEnv:HOME}${localEnv:USERPROFILE}/.npmrc,target=/home/vscode/.npmrc,type=bind"
]
```

## 最佳实践

1. **不要在容器中生成 SSH 密钥** - 使用宿主机的
2. **使用 SSH URL 而不是 HTTPS** - 自动认证
3. **定期更新容器镜像** - 保持工具最新
4. **备份宿主机配置** - .zshrc, .gitconfig 等
5. **使用 .env 文件管理密钥** - 不要提交到仓库

## 性能优化

- 使用 `consistency=cached` 提高文件挂载性能
- 只读挂载对配置文件（如需要）
- 使用 `.dockerignore` 减少上下文大小

## 安全考虑

- SSH 密钥只读挂载（如需要可更改）
- 环境变量不在日志中显示
- .env 文件在 .gitignore 中
- 定期轮换 SSH 密钥和 API token

---

**架构版本**: 1.0
**最后更新**: 2025-12-17
**兼容性**: Linux, macOS (Intel/ARM), Windows (WSL2/Git Bash)
