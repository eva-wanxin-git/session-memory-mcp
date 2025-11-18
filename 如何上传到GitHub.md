# 📤 如何上传到 GitHub

## 🎯 三种方法

---

## 方法一：使用现有仓库（推荐）

如果你已经有 session-memory-mcp 仓库：

```powershell
# 在 Windows 上，进入项目目录
cd session-memory-mcp

# 添加所有文件
git add .

# 提交更改
git commit -m "🍎 添加 Mac 安装支持

- 添加 Mac 一键安装脚本
- 添加 Mac 使用文档
- 添加备份脚本
- 配置 .gitignore"

# 推送到 GitHub
git push origin main
```

---

## 方法二：创建新仓库

### 1. 在 GitHub 上创建仓库

访问: https://github.com/new

填写信息：
- **仓库名**: `session-memory-mcp`
- **描述**: `Session Memory MCP Service - Cross-platform (Windows/Mac)`
- **公开/私有**: 根据需要选择
- **不要**勾选 "Initialize with README"（我们已经有了）

点击 "Create repository"

### 2. 推送代码

```powershell
# 在 Windows 上，进入项目目录
cd session-memory-mcp

# 初始化 Git（如果还没有）
git init

# 添加所有文件
git add .

# 提交
git commit -m "🍎 Initial commit with Mac support"

# 设置主分支
git branch -M main

# 添加远程仓库
git remote add origin https://github.com/你的用户名/session-memory-mcp.git

# 推送
git push -u origin main
```

---

## 方法三：使用自动化脚本

如果你有配置好的同步脚本：

```powershell
# 使用 GitHub 同步管理器
cd ..
python github_sync_manager.py --sync session-memory-mcp
```

或使用一键同步：

```powershell
.\一键启动同步.bat
```

---

## 📦 上传后的仓库结构

```
session-memory-mcp/
├── src/
│   └── index.js              # MCP 服务主程序
├── .env.template             # 配置模板（不包含敏感信息）
├── .gitignore               # Git 忽略规则
├── install-mac.sh           # ⭐ Mac 安装脚本
├── package.json             # Node.js 依赖
├── README.md                # Windows 说明
├── README-MAC.md            # ⭐ Mac 说明
├── 🍎备份到Mac.ps1          # Windows 备份脚本
├── 🍎发给Mac的安装指令.md    # ⭐ 快速指令
└── 如何上传到GitHub.md       # 本文件
```

---

## ✅ 验证上传

### 1. 检查远程仓库

访问: `https://github.com/你的用户名/session-memory-mcp`

确认所有文件都已上传。

### 2. 测试 Mac 克隆

在 Mac 上测试：

```bash
git clone https://github.com/你的用户名/session-memory-mcp.git
cd session-memory-mcp
ls -la
```

应该看到所有文件。

---

## 🔐 安全检查

### 确认没有上传敏感信息

```powershell
# 检查 .gitignore 是否生效
git status

# 确保以下文件不在追踪中：
# ✅ .env (敏感配置)
# ✅ node_modules/ (依赖包)
# ✅ *.log (日志文件)
```

### 如果不小心上传了敏感文件

```powershell
# 从 Git 历史中删除敏感文件
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch .env" \
  --prune-empty --tag-name-filter cat -- --all

# 强制推送（⚠️ 谨慎使用）
git push origin --force --all
```

---

## 📖 Mac 用户安装

上传成功后，发送以下指令给你的 Mac：

```bash
git clone https://github.com/eva-wanxin-git/session-memory-mcp.git
cd session-memory-mcp
chmod +x install-mac.sh
./install-mac.sh
```

详细指令查看: `🍎发给Mac的安装指令.md`

---

## 🔄 后续更新

### 更新代码

```powershell
# Windows 上修改代码后
git add .
git commit -m "描述你的更改"
git push
```

### Mac 上同步更新

```bash
cd session-memory-mcp
git pull origin main
npm install
```

---

## 📊 GitHub 仓库设置建议

### 1. 添加仓库描述

在 GitHub 仓库页面：
- 点击 "About" 旁边的 ⚙️ 设置
- 添加描述：`Session Memory MCP - 跨平台记忆服务（Windows/Mac）`
- 添加主题标签：`mcp`, `cursor`, `ai`, `memory`, `cross-platform`

### 2. 启用 Discussions（可选）

方便用户讨论和反馈。

### 3. 添加 License（可选）

推荐使用 MIT License。

---

## 🎉 完成确认

上传成功后，你应该能够：

- ✅ 在 GitHub 上看到完整代码
- ✅ Mac 用户可以一键克隆安装
- ✅ 跨平台同步代码更新
- ✅ 敏感信息已被 .gitignore 保护

---

## 📞 需要帮助？

如果遇到问题：

1. **权限错误**: 检查 GitHub Token 是否有效
2. **推送失败**: 确认远程仓库地址正确
3. **文件缺失**: 检查 .gitignore 配置

---

**签名: Eva Windows Cursor** 🍎

---

**Session Memory MCP - 跨平台记忆服务** 🧠

