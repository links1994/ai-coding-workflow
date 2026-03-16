#!/bin/bash

# AI Agent 编排框架初始化脚本 (Unix/Mac)
# 用法: ./init.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 框架根目录
FRAMEWORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║         AI Agent 编排框架初始化工具                          ║"
echo "║                                                              ║"
echo "║  支持: 代码开发 | 知识管理 | 内容创作                        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# ==================== 步骤 1: 选择场景 ====================
echo -e "${YELLOW}[1/4] 选择使用场景:${NC}"
echo ""
echo "  工程型:"
echo "    1) 团队开发 (engineering-team)     - 多仓库、CI/CD、协作"
echo "    2) 个人开发 (engineering-solo)     - 单仓库、快速迭代"
echo "    3) 开源贡献 (engineering-oss)      - 社区协作、标准化"
echo ""
echo "  创作型:"
echo "    4) 内容创作 (creation-writing)     - 写作、编辑、发布"
echo "    5) 专题研究 (creation-research)    - 调研、分析、报告"
echo ""
echo "  管理型:"
echo "    6) 知识管理 (management-knowledge) - 收集、整理、关联"
echo "    7) 信息整合 (management-information) - 多源收集、去重"
echo ""

while true; do
    read -p "请输入选项 (1-7): " scenario_choice
    case $scenario_choice in
        1) SCENARIO="engineering-team"; SCENARIO_NAME="团队开发"; break;;
        2) SCENARIO="engineering-solo"; SCENARIO_NAME="个人开发"; break;;
        3) SCENARIO="engineering-oss"; SCENARIO_NAME="开源贡献"; break;;
        4) SCENARIO="creation-writing"; SCENARIO_NAME="内容创作"; break;;
        5) SCENARIO="creation-research"; SCENARIO_NAME="专题研究"; break;;
        6) SCENARIO="management-knowledge"; SCENARIO_NAME="知识管理"; break;;
        7) SCENARIO="management-information"; SCENARIO_NAME="信息整合"; break;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done

echo -e "  → 已选择: ${GREEN}$SCENARIO_NAME${NC}"
echo ""

# ==================== 步骤 2: 选择语言 ====================
echo -e "${YELLOW}[2/4] 选择工作语言:${NC}"
echo ""
echo "  1) 中文"
echo "  2) English"
echo ""

while true; do
    read -p "请输入选项 (1-2): " lang_choice
    case $lang_choice in
        1) LANG="zh"; LANG_NAME="中文"; break;;
        2) LANG="en"; LANG_NAME="English"; break;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done

echo -e "  → 已选择: ${GREEN}$LANG_NAME${NC}"
echo ""

# ==================== 步骤 3: 配置仓库 ====================
echo -e "${YELLOW}[3/4] 配置仓库结构:${NC}"
echo ""
echo "  1) 单仓库 - 所有代码在一个仓库中"
echo "  2) 多仓库 - 多个独立仓库（适合团队/复杂项目）"
echo ""

while true; do
    read -p "请输入选项 (1-2): " repo_choice
    case $repo_choice in
        1) REPO_MODE="single"; REPO_NAME="单仓库"; break;;
        2) REPO_MODE="multi"; REPO_NAME="多仓库"; break;;
        *) echo -e "${RED}无效选项，请重新输入${NC}";;
    esac
done

echo -e "  → 已选择: ${GREEN}$REPO_NAME${NC}"
echo ""

# ==================== 步骤 4: 确认配置 ====================
echo -e "${YELLOW}[4/4] 确认配置:${NC}"
echo ""
echo "  场景: $SCENARIO_NAME"
echo "  语言: $LANG_NAME"
echo "  仓库: $REPO_NAME"
echo ""

read -p "确认初始化? (y/n): " confirm
if [[ $confirm != "y" && $confirm != "Y" ]]; then
    echo -e "${YELLOW}已取消初始化${NC}"
    exit 0
fi

echo ""
echo -e "${BLUE}开始初始化...${NC}"
echo ""

# ==================== 执行初始化 ====================

# 1. 复制场景模板
echo "  → 复制场景模板: $SCENARIO"
if [ -f "$FRAMEWORK_DIR/templates/$SCENARIO/RESOURCE-MAP.yml" ]; then
    cp "$FRAMEWORK_DIR/templates/$SCENARIO/RESOURCE-MAP.yml" "$FRAMEWORK_DIR/orchestrator/ALWAYS/RESOURCE-MAP.yml"
    echo -e "    ${GREEN}✓${NC} 已应用 $SCENARIO 资源映射"
else
    echo -e "    ${YELLOW}⚠${NC} 场景模板不存在，使用默认配置"
fi

# 2. 更新 AGENTS.md 语言设置
echo "  → 配置工作语言: $LANG_NAME"
if [ -f "$FRAMEWORK_DIR/AGENTS.md" ]; then
    if [ "$LANG" = "zh" ]; then
        sed -i '' 's/工作语言与风格.*/工作语言与风格\n\n- 中文/' "$FRAMEWORK_DIR/AGENTS.md" 2>/dev/null || \
        sed -i 's/工作语言与风格.*/工作语言与风格\n\n- 中文/' "$FRAMEWORK_DIR/AGENTS.md"
    else
        sed -i '' 's/工作语言与风格.*/工作语言与风格\n\n- English/' "$FRAMEWORK_DIR/AGENTS.md" 2>/dev/null || \
        sed -i 's/工作语言与风格.*/工作语言与风格\n\n- English/' "$FRAMEWORK_DIR/AGENTS.md"
    fi
    echo -e "    ${GREEN}✓${NC} 已更新 AGENTS.md"
fi

# 3. 创建用户工作目录
echo "  → 创建工作目录"
mkdir -p "$FRAMEWORK_DIR/outputs/code/repos"
mkdir -p "$FRAMEWORK_DIR/outputs/documents"
mkdir -p "$FRAMEWORK_DIR/outputs/data"
mkdir -p "$FRAMEWORK_DIR/inputs/products"
mkdir -p "$FRAMEWORK_DIR/inputs/references"
mkdir -p "$FRAMEWORK_DIR/orchestrator/PROGRAMS"
echo -e "    ${GREEN}✓${NC} 已创建工作目录"

# 4. 根据仓库模式创建结构
if [ "$REPO_MODE" = "multi" ]; then
    echo "  → 配置多仓库结构"
    mkdir -p "$FRAMEWORK_DIR/outputs/code/repos/project-1"
    mkdir -p "$FRAMEWORK_DIR/outputs/code/repos/project-2"
    echo -e "    ${GREEN}✓${NC} 已创建多仓库目录"
fi

# ==================== 完成 ====================
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                   初始化完成!                                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "  场景: $SCENARIO_NAME"
echo "  语言: $LANG_NAME"
echo "  仓库: $REPO_NAME"
echo ""
echo -e "${BLUE}下一步:${NC}"
echo ""
echo "  1. 查看 README.md 了解框架详情"
echo "  2. 编辑 orchestrator/ALWAYS/RESOURCE-MAP.yml 配置你的资源"
echo "  3. 创建新 Program:"
echo "     cp -r orchestrator/PROGRAMS_TEMPLATE/P-YYYY-NNN-name orchestrator/PROGRAMS/P-2026-001-my-task"
echo ""
echo "  4. 开始使用:"
echo "     - 新 Program: xxx"
echo "     - 继续 P-2026-001"
echo ""
