# Claude Code 开发容器

一个完整的 Claude Code 开发容器，支持多种编程语言和完全配置的 zsh 环境。

## 功能特性

- **Shell**：zsh + oh-my-zsh（包含 git 和 z 插件）
- **编程语言**：
  - Python 3.13.1（通过 pyenv 管理）
  - Go 1.23.4
  - Node.js 24.12.0（通过 nvm 管理）
  - Ruby 3.4.1（通过 rbenv 管理）
- **开发工具**：git、tig、ssh、Claude Code
- **跨平台**：支持 Windows、macOS 和 Linux
- **自动初始化**：首次启动时自动跳过 Claude Code 引导流程

## 前置要求

1. 安装 [Docker](https://www.docker.com/products/docker-desktop)
2. 安装 [VS Code](https://code.visualstudio.com/) 及 [Dev Containers 扩展](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. 获取 Anthropic API Token

## 快速开始

### 1. 配置环境变量（必须）

**重要提示**：为了安全性，强烈建议将 `ANTHROPIC_AUTH_TOKEN` 设置在**宿主机系统环境变量**中，而不是 `.env` 文件中。其他配置参数可以放在 `.env` 文件中。

#### 方式 A：宿主机环境变量 + .env 文件（推荐）

**步骤 1**：在宿主机系统中设置 API Token

**macOS/Linux**：添加到 `~/.zshrc` 或 `~/.bashrc`
```bash
export ANTHROPIC_AUTH_TOKEN=sk-your-actual-token-here
```

**Windows**：在系统环境变量中设置
```powershell
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'sk-your-token', 'User')
```

**步骤 2**：创建 .env 文件配置其他参数

```bash
# 复制示例文件到 .devcontainer 目录
cp .devcontainer/.env.example .devcontainer/.env

# 编辑 .env 文件，配置其他参数（不包含 ANTHROPIC_AUTH_TOKEN）
vim .devcontainer/.env
```

**.env 文件示例（位于 .devcontainer/.env）：**
```bash
# 注意：ANTHROPIC_AUTH_TOKEN 应该设置在系统环境变量中，不要写在这里

# API Base URL (Claude official API endpoint)
ANTHROPIC_BASE_URL=https://api.anthropic.com

# API timeout in milliseconds (10 minutes)
API_TIMEOUT_MS=600000

# Claude model to use
ANTHROPIC_MODEL=claude-4.5-sonnet

# Small/fast model for quick operations
ANTHROPIC_SMALL_FAST_MODEL=claude-4.5-sonnet

# Disable non-essential network traffic
CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

#### 方式 B：完全使用宿主机环境变量

如果你不想使用 .env 文件，可以将所有配置都设置在宿主机环境变量中：

**macOS/Linux**：添加到 `~/.zshrc` 或 `~/.bashrc`
```bash
export ANTHROPIC_AUTH_TOKEN=sk-your-actual-token-here
export ANTHROPIC_BASE_URL=https://api.anthropic.com
export API_TIMEOUT_MS=600000
export ANTHROPIC_MODEL=claude-4.5-sonnet
export ANTHROPIC_SMALL_FAST_MODEL=claude-4.5-sonnet
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1
```

**Windows**：在系统环境变量中设置，或在 PowerShell 配置文件中添加
```powershell
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_AUTH_TOKEN', 'sk-your-token', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_BASE_URL', 'https://api.anthropic.com', 'User')
[System.Environment]::SetEnvironmentVariable('API_TIMEOUT_MS', '600000', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_MODEL', 'claude-4.5-sonnet', 'User')
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_SMALL_FAST_MODEL', 'claude-4.5-sonnet', 'User')
[System.Environment]::SetEnvironmentVariable('CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC', '1', 'User')
```

### 2. 在容器中打开项目

1. 在 VS Code 中打开此文件夹
2. 按 `F1` 并选择 `Dev Containers: Reopen in Container`
3. 等待容器构建（首次构建需要 5-10 分钟）
4. 构建完成后，你将拥有一个完全配置好的开发环境

容器启动时会自动执行初始化脚本：
- 设置 Claude Code 配置（`~/.claude.json`）
- 跳过引导流程（设置 `hasCompletedOnboarding: true`）
- 验证所有开发工具是否正确安装

## 验证安装

容器启动后，验证所有工具是否正确安装：

```bash
# 检查版本
claude --version
python --version
go version
ruby --version
node --version
git --version
tig --version
```

## 使用环境

### zsh 与 oh-my-zsh

默认 shell 是 zsh，配置了 oh-my-zsh 和以下插件：
- **git 插件**：增强的 git 命令和别名
- **z 插件**：使用 `z <目录名>` 快速跳转到常用目录

### 环境变量优先级

环境变量按以下优先级加载：
1. 宿主机环境变量（通过 `${localEnv:VAR}` 传递）
2. `.env` 文件（位于 `.devcontainer/.env`）
3. 未设置（变量为空）

所有来自 `.env` 文件的环境变量会在新建 shell 会话时自动加载。

### Git 配置

你的 SSH 密钥和 git 配置会自动从宿主机挂载到容器：
- `~/.ssh` → `/home/vscode/.ssh`（只读）
- `~/.gitconfig` → `/home/vscode/.gitconfig`（只读）

你可以使用现有的 SSH 密钥来提交和推送代码到 git 仓库。

### 运行 Claude Code

```bash
# 启动 Claude Code
claude

# 检查环境变量
echo $ANTHROPIC_AUTH_TOKEN
echo $ANTHROPIC_BASE_URL
```

## 自定义配置

### 添加更多 VS Code 扩展

编辑 `.devcontainer/devcontainer.json`，在 `extensions` 数组中添加扩展 ID：

```json
"extensions": [
  "ms-python.python",
  "golang.go",
  "dbaeumer.vscode-eslint"
]
```

### 修改环境变量

编辑 `.env` 文件或修改宿主机环境变量即可。

### 更改语言版本

编辑 `.devcontainer/Dockerfile` 并更新版本号：
- Python：修改 `pyenv install 3.13.1`
- Go：修改下载 URL `go1.23.4.linux-amd64.tar.gz`
- Node.js：修改 `nvm install 24.12.0`
- Ruby：修改 `rbenv install 3.4.1`

## 故障排除

### 容器构建失败

- 检查 Docker 是否分配了足够的内存（建议 4GB+）
- 检查网络连接是否正常（需要下载各种语言版本）
- 查看构建日志中的具体错误信息

### Claude Code 认证失败

- 验证 `ANTHROPIC_AUTH_TOKEN` 是否设置正确
- 检查 token 是否有效：`echo $ANTHROPIC_AUTH_TOKEN`
- 尝试在宿主机环境变量中设置 token，然后重新构建容器

### SSH/Git 无法工作

- 确保 SSH 密钥在宿主机上存在：`ls -la ~/.ssh`
- 检查 SSH 密钥权限（私钥应该是 600）
- 验证 git 配置存在：`cat ~/.gitconfig`

### 环境变量未加载

- 检查 `.env` 文件是否存在：`ls -la /workspace/.env`
- 手动加载文件：`source /workspace/.env`
- 验证 `.env` 语法（等号周围不要有空格）
- 检查 `.env` 文件是否在项目根目录

### 工具版本不正确

```bash
# Python 版本不正确
pyenv global 3.13.1
pyenv rehash

# Node.js 版本不正确
nvm use 24.12.0

# Ruby 版本不正确
rbenv global 3.4.1
rbenv rehash
```

## 性能优化建议

1. **使用持久化卷**：项目工作区使用 bind mount 挂载，性能最佳
2. **仅在需要时重新构建**：修改 Dockerfile 后使用 `Dev Containers: Rebuild Container`
3. **安装全局工具**：使用语言包管理器（pip、npm、gem、go install）安装项目依赖

## 架构说明

```
宿主机
├── 项目文件（挂载到 /workspace）
├── .env（挂载并自动加载）
├── ~/.ssh（只读挂载）
└── ~/.gitconfig（只读挂载）

容器
├── /workspace（你的项目）
├── /home/vscode/.pyenv（Python 3.13.1）
├── /home/vscode/.nvm（Node.js 24.12.0）
├── /home/vscode/.rbenv（Ruby 3.4.1）
├── /usr/local/go（Go 1.23.4）
└── zsh + oh-my-zsh（包含 git 和 z 插件）
```

## 环境变量说明

| 变量名 | 说明 | 必需 | 示例值 |
|--------|------|------|--------|
| `ANTHROPIC_AUTH_TOKEN` | Anthropic API Token | ✅ 是 | `sk-ant-xxx` |
| `ANTHROPIC_BASE_URL` | API 基础 URL | ✅ 是 | `https://api.anthropic.com` |
| `API_TIMEOUT_MS` | API 超时时间（毫秒） | ✅ 是 | `600000` |
| `ANTHROPIC_MODEL` | 使用的模型 | ✅ 是 | `claude-4.5-sonnet` |
| `ANTHROPIC_SMALL_FAST_MODEL` | 快速操作使用的小模型 | ✅ 是 | `claude-4.5-sonnet` |
| `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC` | 禁用非必要网络流量 | ✅ 是 | `1` |

**重要提示**：所有环境变量都是必需的，必须在宿主机环境变量或 `.env` 文件中设置。

## 常见问题

### Q: 为什么需要设置这么多环境变量？

A: 这些环境变量用于配置 Claude Code 的 API 连接。容器本身不包含任何默认配置，以确保灵活性和安全性。

### Q: 我可以同时使用宿主机环境变量和 .env 文件吗？

A: 可以。宿主机环境变量的优先级更高，会覆盖 .env 文件中的值。

### Q: 如何更新容器中的语言版本？

A: 编辑 `.devcontainer/Dockerfile`，修改相应的版本号，然后在 VS Code 中运行 `Dev Containers: Rebuild Container`。

### Q: 容器启动很慢怎么办？

A: 首次启动需要下载和安装所有语言和工具，这是正常的。后续启动会快很多。如果每次都很慢，检查 Docker 的资源分配。

### Q: 如何在容器内提交代码？

A: 容器已经挂载了你的 SSH 密钥和 git 配置，直接使用 `git commit` 和 `git push` 即可。

## 贡献

欢迎根据你的需求自定义此 devcontainer。常见的修改包括：
- 添加更多语言版本
- 包含额外的开发工具
- 配置额外的 VS Code 设置
- 添加自定义 zsh 插件

## 许可证

此 devcontainer 配置按原样提供，用于开发目的。

## 相关文档

- [TESTING.md](TESTING.md) - 测试指南和故障排除详细说明
- [README.md](README.md) - 英文版文档
