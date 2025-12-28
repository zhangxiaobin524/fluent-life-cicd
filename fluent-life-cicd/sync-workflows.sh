#!/bin/bash

# 同步脚本：将 fluent-life-cicd 目录下的 workflow 文件同步到 .github/workflows/
# 使用方法: cd fluent-life-cicd && ./sync-workflows.sh

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 获取脚本所在目录（fluent-life-cicd）
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"
WORKFLOWS_DIR="$PROJECT_ROOT/.github/workflows"

# 检查是否在正确的目录
if [ "$(basename "$SCRIPT_DIR")" != "fluent-life-cicd" ]; then
    echo -e "${RED}❌ 脚本应在 fluent-life-cicd 目录下运行${NC}"
    exit 1
fi

# 确保 .github/workflows 目录存在
if [ ! -d "$WORKFLOWS_DIR" ]; then
    echo -e "${YELLOW}⚠️  创建 .github/workflows 目录...${NC}"
    mkdir -p "$WORKFLOWS_DIR"
fi

echo "🔄 同步 workflow 文件..."
echo "源目录: $SCRIPT_DIR"
echo "目标目录: $WORKFLOWS_DIR"
echo ""

# 同步所有 .yml 文件
SYNCED=0
for file in "$SCRIPT_DIR"/*.yml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        dest="$WORKFLOWS_DIR/$filename"
        
        if [ -f "$dest" ]; then
            # 检查文件是否有变化
            if ! cmp -s "$file" "$dest"; then
                cp "$file" "$dest"
                echo -e "${GREEN}✅ 更新: $filename${NC}"
                SYNCED=$((SYNCED + 1))
            else
                echo -e "⏭️  跳过: $filename (无变化)"
            fi
        else
            cp "$file" "$dest"
            echo -e "${GREEN}✅ 新增: $filename${NC}"
            SYNCED=$((SYNCED + 1))
        fi
    fi
done

if [ $SYNCED -eq 0 ]; then
    echo -e "${YELLOW}⚠️  没有文件需要同步${NC}"
else
    echo ""
    echo -e "${GREEN}✅ 同步完成！已同步 $SYNCED 个文件${NC}"
fi

echo ""
echo "📝 提示："
echo "  - 在 fluent-life-cicd/ 目录下编辑 workflow 文件"
echo "  - 运行此脚本同步到 .github/workflows/"
echo "  - GitHub Actions 会从 .github/workflows/ 读取配置"
echo ""

