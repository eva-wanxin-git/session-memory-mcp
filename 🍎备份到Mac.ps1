# Session Memory MCP - Mac 同步备份脚本
# 用途: 在 Windows 上创建完整备份，准备在 Mac 上安装

$ErrorActionPreference = "Stop"

Write-Host "🍎 Session Memory MCP - Mac 同步备份" -ForegroundColor Green
Write-Host "=" * 60

# 配置
$projectName = "session-memory-mcp"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = "$env:USERPROFILE\Desktop\$projectName-Mac-备份-$timestamp"
$zipFile = "$env:USERPROFILE\Desktop\$projectName-Mac-安装包-$timestamp.zip"

# 创建备份目录
Write-Host "`n📁 创建备份目录..." -ForegroundColor Cyan
New-Item -ItemType Directory -Path $backupDir -Force | Out-Null

# 1. 复制源代码
Write-Host "📦 复制源代码..." -ForegroundColor Cyan
$sourceDir = $PSScriptRoot
Copy-Item "$sourceDir\src" -Destination "$backupDir\src" -Recurse -Force
Copy-Item "$sourceDir\package.json" -Destination "$backupDir\" -Force
Copy-Item "$sourceDir\package-lock.json" -Destination "$backupDir\" -Force -ErrorAction SilentlyContinue

# 2. 创建配置模板
Write-Host "⚙️  创建配置模板..." -ForegroundColor Cyan
$envTemplate = @"
# Session Memory MCP 配置
# 请根据实际情况修改

# API 服务器地址
SESSION_MEMORY_API_URL=http://13.158.83.99:4000

# 默认用户ID
DEFAULT_USER_ID=wanxin

# 默认平台
DEFAULT_PLATFORM=cursor
"@

$envTemplate | Out-File -FilePath "$backupDir\.env.template" -Encoding UTF8

# 3. 创建 Mac 安装脚本
Write-Host "🚀 创建 Mac 安装脚本..." -ForegroundColor Cyan
$macInstallScript = @'
#!/bin/bash
# Session Memory MCP - Mac 一键安装脚本

set -e

echo "🍎 Session Memory MCP - Mac 安装程序"
echo "=========================================="

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

echo ""
echo -e "${BLUE}📋 第一步: 检查系统依赖${NC}"
echo "=========================================="

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ Node.js 未安装${NC}"
    echo "请运行: brew install node"
    exit 1
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}✅ Node.js 已安装: $NODE_VERSION${NC}"

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm 未安装${NC}"
    exit 1
fi

NPM_VERSION=$(npm --version)
echo -e "${GREEN}✅ npm 已安装: $NPM_VERSION${NC}"

# 检查 git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠️  git 未安装，建议安装: brew install git${NC}"
fi

echo ""
echo -e "${BLUE}📦 第二步: 安装依赖包${NC}"
echo "=========================================="

npm install
echo -e "${GREEN}✅ 依赖包安装完成${NC}"

echo ""
echo -e "${BLUE}⚙️  第三步: 配置环境${NC}"
echo "=========================================="

# 创建 .env 文件
if [ ! -f ".env" ]; then
    if [ -f ".env.template" ]; then
        cp .env.template .env
        echo -e "${GREEN}✅ 已创建 .env 配置文件${NC}"
        echo -e "${YELLOW}⚠️  请编辑 .env 文件，配置您的参数${NC}"
    else
        echo -e "${RED}❌ 找不到 .env.template 文件${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ .env 文件已存在${NC}"
fi

echo ""
echo -e "${BLUE}🔧 第四步: 配置 Cursor MCP${NC}"
echo "=========================================="

# 获取当前目录的绝对路径
INSTALL_PATH="$SCRIPT_DIR"

# Cursor 配置文件路径（Mac）
CURSOR_CONFIG_DIR="$HOME/Library/Application Support/Cursor/User/globalStorage/saoudrizwan.claude-dev"
CURSOR_CONFIG_FILE="$CURSOR_CONFIG_DIR/settings/cline_mcp_settings.json"

echo "安装路径: $INSTALL_PATH"
echo "Cursor 配置路径: $CURSOR_CONFIG_FILE"

# 创建配置目录
mkdir -p "$CURSOR_CONFIG_DIR/settings"

# 生成 MCP 配置
cat > "$CURSOR_CONFIG_FILE" << EOF
{
  "mcpServers": {
    "session-memory": {
      "command": "node",
      "args": [
        "$INSTALL_PATH/src/index.js"
      ],
      "env": {
        "SESSION_MEMORY_API_URL": "http://13.158.83.99:4000",
        "DEFAULT_USER_ID": "wanxin",
        "DEFAULT_PLATFORM": "cursor"
      }
    }
  }
}
EOF

echo -e "${GREEN}✅ Cursor MCP 配置已创建${NC}"

echo ""
echo -e "${BLUE}🧪 第五步: 测试服务${NC}"
echo "=========================================="

# 测试 API 连接
echo "测试 API 连接..."
if curl -s --connect-timeout 5 "http://13.158.83.99:4000/api/health" > /dev/null; then
    echo -e "${GREEN}✅ API 服务器连接正常${NC}"
else
    echo -e "${YELLOW}⚠️  API 服务器连接失败，请检查网络或 EC2 实例状态${NC}"
fi

echo ""
echo -e "${GREEN}🎉 安装完成！${NC}"
echo "=========================================="
echo ""
echo "📝 下一步操作:"
echo ""
echo "1. 编辑配置文件（如需要）:"
echo "   nano .env"
echo ""
echo "2. 重启 Cursor 使配置生效"
echo ""
echo "3. 在 Cursor 中测试 MCP 工具:"
echo "   - session_memory_ensure"
echo "   - session_memory_update"
echo "   - session_memory_context"
echo "   - session_memory_end"
echo ""
echo "4. Cursor MCP 配置位置:"
echo "   $CURSOR_CONFIG_FILE"
echo ""
echo "如有问题，请查看 README-MAC.md"
echo ""
echo -e "${BLUE}签名: Eva Windows Cursor 🍎${NC}"
'@

$macInstallScript | Out-File -FilePath "$backupDir\install-mac.sh" -Encoding UTF8

# 4. 创建 Mac README
Write-Host "📖 创建 Mac 使用文档..." -ForegroundColor Cyan
$macReadme = @"
# 🍎 Session Memory MCP - Mac 安装指南

> **从 Windows 到 Mac 的无缝迁移**

---

## 📋 系统要求

- **macOS** 10.15+ (Catalina or later)
- **Node.js** 18+
- **npm** 9+
- **Cursor** IDE

---

## 🚀 三步安装（5分钟）

### 第一步：解压安装包

```bash
# 解压到你想要的位置，例如：
unzip session-memory-mcp-Mac-安装包-*.zip -d ~/Documents/
cd ~/Documents/session-memory-mcp
```

### 第二步：运行安装脚本

```bash
# 添加执行权限
chmod +x install-mac.sh

# 运行安装
./install-mac.sh
```

### 第三步：重启 Cursor

完成！重启 Cursor 后，MCP 工具将自动加载。

---

## 📖 从 GitHub 安装（推荐）

```bash
# 克隆仓库
git clone https://github.com/eva-wanxin-git/session-memory-mcp.git
cd session-memory-mcp

# 运行安装
chmod +x install-mac.sh
./install-mac.sh
```

---

## ⚙️ 配置说明

### .env 文件

默认配置已包含在 ``.env.template`` 中：

```bash
# API 服务器地址（已部署在 AWS EC2）
SESSION_MEMORY_API_URL=http://13.158.83.99:4000

# 你的用户ID
DEFAULT_USER_ID=wanxin

# 使用平台
DEFAULT_PLATFORM=cursor
```

如需修改，编辑 ``.env`` 文件：

```bash
nano .env
```

### Cursor MCP 配置

安装脚本会自动创建配置文件：

**位置**: ``~/Library/Application Support/Cursor/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json``

**内容**:
```json
{
  "mcpServers": {
    "session-memory": {
      "command": "node",
      "args": [
        "/your/path/session-memory-mcp/src/index.js"
      ],
      "env": {
        "SESSION_MEMORY_API_URL": "http://13.158.83.99:4000",
        "DEFAULT_USER_ID": "wanxin",
        "DEFAULT_PLATFORM": "cursor"
      }
    }
  }
}
```

---

## 🧪 测试安装

### 1. 测试 API 连接

```bash
# 测试 API 是否可访问
curl http://13.158.83.99:4000/api/health
```

应该返回: ``{"status":"ok"}``

### 2. 测试 MCP 服务

```bash
# 启动 MCP 服务（测试模式）
node src/index.js
```

应该看到: ``✅ Session Memory MCP Client started``

按 ``Ctrl+C`` 退出测试。

### 3. 在 Cursor 中测试

重启 Cursor 后，在对话中说：

```
我是 eva，帮我创建一个新任务
```

系统会自动使用 MCP 工具创建任务和会话。

---

## 🔧 可用的 MCP 工具

### 1. session_memory_ensure
创建或获取任务，并创建会话

```javascript
{
  "task_id": "task-001",
  "platform": "cursor",
  "scope": "/project/path",
  "content": "任务描述"
}
```

### 2. session_memory_update
更新会话消息

```javascript
{
  "session_id": "session-123",
  "role": "user",  // 或 "assistant"
  "content": "消息内容"
}
```

### 3. session_memory_context
获取任务上下文

```javascript
{
  "task_id": "task-001",
  "max_messages": 20
}
```

### 4. session_memory_end
结束会话

```javascript
{
  "session_id": "session-123"
}
```

---

## 📊 系统架构

\`\`\`
┌─────────────────┐
│   Mac Cursor    │
│   (MCP Client)  │
└────────┬────────┘
         │
         │ HTTP
         ▼
┌─────────────────┐
│  AWS EC2 API    │
│ 13.158.83.99    │
│    :4000        │
└────────┬────────┘
         │
         │ PostgreSQL
         ▼
┌─────────────────┐
│   AWS RDS       │
│   (Database)    │
└─────────────────┘
\`\`\`

---

## 🛠️ 常见问题

### Q1: 无法连接到 API 服务器

**原因**: EC2 实例可能已停止

**解决方案**:
1. 检查 EC2 实例状态
2. 确认安全组允许 4000 端口访问
3. 尝试 ping EC2 IP: ``ping 13.158.83.99``

### Q2: Cursor 找不到 MCP 工具

**原因**: 配置文件路径错误或 Cursor 未重启

**解决方案**:
1. 确认配置文件位置正确
2. 完全退出并重启 Cursor（不是重新加载窗口）
3. 检查 Cursor 开发者工具的错误信息

### Q3: Node.js 版本过低

**解决方案**:
```bash
# 使用 Homebrew 安装最新版
brew install node

# 或使用 nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install 20
nvm use 20
```

### Q4: 权限错误

**解决方案**:
```bash
# 添加执行权限
chmod +x install-mac.sh

# 如果 npm 权限错误
sudo chown -R $(whoami) ~/.npm
```

---

## 🔐 数据安全

### EC2 API 访问

- ✅ API 部署在 AWS EC2 上
- ✅ 数据存储在 AWS RDS (PostgreSQL)
- ✅ 支持跨平台访问（Windows/Mac）
- ⚠️ 确保 EC2 实例正在运行

### 敏感信息

``.gitignore`` 已配置忽略：
- ``.env`` (包含用户配置)
- ``node_modules/`` (依赖包)

---

## 📚 相关文档

- [API 文档](./API.md)
- [EC2 部署指南](./688ffa28-e5e5-42b2-bff1-01dc3ab43bca_Session_Memory_Service_-_EC2_部署完整指南.pdf)
- [Windows 版 README](./README.md)

---

## 🔄 更新和同步

### 从 GitHub 更新

```bash
cd ~/Documents/session-memory-mcp
git pull origin main
npm install
```

### 重新安装

```bash
./install-mac.sh
```

---

## 📞 需要帮助？

- **GitHub Issues**: https://github.com/eva-wanxin-git/session-memory-mcp/issues
- **邮件**: 26287333@qq.com

---

## 🎉 完成确认

安装成功后，你应该能够：

- ✅ 在 Mac 上运行 Session Memory MCP
- ✅ Cursor 自动识别 MCP 工具
- ✅ 创建和管理任务会话
- ✅ 跨平台数据同步（Windows/Mac 共享 EC2 数据）

---

**签名: Eva Windows Cursor**  
**目标: Eva Mac Cursor** 🍎

---

**Session Memory MCP** - 让 AI 拥有持久记忆 🧠
"@

$macReadme | Out-File -FilePath "$backupDir\README-MAC.md" -Encoding UTF8

# 5. 创建 .gitignore
Write-Host "🔒 创建 .gitignore..." -ForegroundColor Cyan
$gitignore = @"
# 依赖
node_modules/
package-lock.json

# 环境配置
.env
.env.local
.env.*.local

# 日志
*.log
npm-debug.log*

# 操作系统
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo

# 测试
coverage/
.nyc_output/

# 临时文件
*.tmp
*.temp
"@

$gitignore | Out-File -FilePath "$backupDir\.gitignore" -Encoding UTF8

# 6. 创建 GitHub 上传说明
Write-Host "📤 创建 GitHub 上传说明..." -ForegroundColor Cyan
$githubGuide = @"
# 📤 上传到 GitHub

## 方法一：使用现有仓库

```powershell
# 在 Windows 上
cd session-memory-mcp

# 添加所有文件
git add .
git commit -m "🍎 添加 Mac 安装支持"
git push origin main
```

## 方法二：创建新仓库

### 1. 在 GitHub 上创建仓库

访问: https://github.com/new

- 仓库名: ``session-memory-mcp``
- 描述: ``Session Memory MCP - Cross-platform (Windows/Mac)``
- 公开/私有: 根据需要选择

### 2. 推送代码

```powershell
cd $backupDir
git init
git add .
git commit -m "🍎 Initial commit with Mac support"
git branch -M main
git remote add origin https://github.com/eva-wanxin-git/session-memory-mcp.git
git push -u origin main
```

## 方法三：自动化脚本

```powershell
# 使用项目根目录的同步脚本
cd ..
python github_sync_manager.py --sync session-memory-mcp
```

---

## 📦 仓库结构

```
session-memory-mcp/
├── src/
│   └── index.js              # MCP 服务主程序
├── .env.template             # 配置模板
├── .gitignore               # Git 忽略规则
├── install-mac.sh           # Mac 安装脚本
├── package.json             # Node.js 依赖
├── README.md                # Windows 说明
├── README-MAC.md            # Mac 说明
└── 如何上传到GitHub.md       # 本文件
```

---

## ✅ 上传完成后

### Mac 用户可以直接安装：

```bash
git clone https://github.com/eva-wanxin-git/session-memory-mcp.git
cd session-memory-mcp
chmod +x install-mac.sh
./install-mac.sh
```

---

**签名: Eva Windows Cursor** 🍎
"@

$githubGuide | Out-File -FilePath "$backupDir\如何上传到GitHub.md" -Encoding UTF8

# 7. 创建快速指令文件
Write-Host "📝 创建快速指令..." -ForegroundColor Cyan
$quickStart = @"
# 🍎 发给 Mac 用户的快速安装指令

复制以下内容发给你的 Mac：

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🍎 **Session Memory MCP - Mac 一键安装**

打开终端（Terminal），复制粘贴：

``````bash
# 从 GitHub 安装（推荐）
git clone https://github.com/eva-wanxin-git/session-memory-mcp.git
cd session-memory-mcp
chmod +x install-mac.sh
./install-mac.sh
``````

或从本地安装（如果已有安装包）：

``````bash
# 解压安装包
unzip session-memory-mcp-Mac-安装包-*.zip -d ~/Documents/
cd ~/Documents/session-memory-mcp

# 运行安装
chmod +x install-mac.sh
./install-mac.sh
``````

**完成后重启 Cursor！**

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

详细说明查看: README-MAC.md

签名: Eva Windows Cursor 🍎
"@

$quickStart | Out-File -FilePath "$backupDir\🍎发给Mac的安装指令.md" -Encoding UTF8

# 8. 压缩打包
Write-Host "`n📦 压缩打包..." -ForegroundColor Cyan
Compress-Archive -Path "$backupDir\*" -DestinationPath $zipFile -Force

# 清理临时目录
Remove-Item $backupDir -Recurse -Force

# 完成
Write-Host "`n✅ 备份完成！" -ForegroundColor Green
Write-Host "=" * 60
Write-Host "`n📦 安装包位置:" -ForegroundColor Cyan
Write-Host "   $zipFile" -ForegroundColor Yellow
Write-Host "`n📝 包含文件:" -ForegroundColor Cyan
Write-Host "   ✅ 源代码 (src/)"
Write-Host "   ✅ 依赖配置 (package.json)"
Write-Host "   ✅ Mac 安装脚本 (install-mac.sh)"
Write-Host "   ✅ Mac 使用文档 (README-MAC.md)"
Write-Host "   ✅ 配置模板 (.env.template)"
Write-Host "   ✅ Git 配置 (.gitignore)"
Write-Host "   ✅ GitHub 上传说明"
Write-Host "   ✅ 快速安装指令"

Write-Host "`n📤 下一步操作:" -ForegroundColor Cyan
Write-Host "   1. 上传到 GitHub:"
Write-Host "      cd session-memory-mcp"
Write-Host "      git add ."
Write-Host "      git commit -m '🍎 添加 Mac 支持'"
Write-Host "      git push"
Write-Host ""
Write-Host "   2. 或直接发送安装包给你的 Mac"
Write-Host ""
Write-Host "   3. Mac 上运行:"
Write-Host "      git clone https://github.com/eva-wanxin-git/session-memory-mcp.git"
Write-Host "      cd session-memory-mcp"
Write-Host "      chmod +x install-mac.sh"
Write-Host "      ./install-mac.sh"

Write-Host "`n🍎 签名: Eva Windows Cursor" -ForegroundColor Green
Write-Host ""

