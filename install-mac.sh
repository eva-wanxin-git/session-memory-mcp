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
    cat > .env << EOF
# Session Memory MCP 配置
SESSION_MEMORY_API_URL=http://13.158.83.99:4000
DEFAULT_USER_ID=wanxin
DEFAULT_PLATFORM=cursor
EOF
    echo -e "${GREEN}✅ 已创建 .env 配置文件${NC}"
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

