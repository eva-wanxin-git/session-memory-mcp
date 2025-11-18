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

### 第一步：克隆仓库

```bash
# 从 GitHub 克隆（推荐）
git clone https://github.com/eva-wanxin-git/session-memory-mcp.git
cd session-memory-mcp
```

或从本地安装包：

```bash
# 解压安装包
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

安装脚本会自动：
- ✅ 检查系统依赖（Node.js, npm）
- ✅ 安装 npm 包
- ✅ 创建配置文件
- ✅ 配置 Cursor MCP
- ✅ 测试 API 连接

### 第三步：重启 Cursor

完成！重启 Cursor 后，MCP 工具将自动加载。

---

## ⚙️ 配置说明

### .env 文件

默认配置已包含在 `.env.template` 中：

```bash
# API 服务器地址（已部署在 AWS EC2）
SESSION_MEMORY_API_URL=http://13.158.83.99:4000

# 你的用户ID
DEFAULT_USER_ID=wanxin

# 使用平台
DEFAULT_PLATFORM=cursor
```

如需修改，编辑 `.env` 文件：

```bash
nano .env
```

### Cursor MCP 配置

安装脚本会自动创建配置文件：

**位置**: `~/Library/Application Support/Cursor/User/globalStorage/saoudrizwan.claude-dev/settings/cline_mcp_settings.json`

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

应该返回: `{"status":"ok"}`

### 2. 测试 MCP 服务

```bash
# 启动 MCP 服务（测试模式）
node src/index.js
```

应该看到: `✅ Session Memory MCP Client started`

按 `Ctrl+C` 退出测试。

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

```
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
```

---

## 🛠️ 常见问题

### Q1: 无法连接到 API 服务器

**原因**: EC2 实例可能已停止

**解决方案**:
1. 检查 EC2 实例状态
2. 确认安全组允许 4000 端口访问
3. 尝试 ping EC2 IP: `ping 13.158.83.99`

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

`.gitignore` 已配置忽略：
- `.env` (包含用户配置)
- `node_modules/` (依赖包)

---

## 🔄 更新和同步

### 从 GitHub 更新

```bash
cd ~/session-memory-mcp
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

