#!/bin/bash

#===============================================================================
# DockEase 直接运行脚本
# 用法: curl -fsSL https://your-domain.com/run.sh | bash
# 或者: bash <(curl -fsSL https://your-domain.com/run.sh)
#===============================================================================

set -uo pipefail

# 配置
DOCKEASE_URL="https://raw.githubusercontent.com/NekoNuo/DockEase/main/dockease.sh"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查下载工具
if command -v curl &> /dev/null; then
    DOWNLOAD_CMD="curl -fsSL"
elif command -v wget &> /dev/null; then
    DOWNLOAD_CMD="wget -qO-"
else
    print_error "需要 curl 或 wget 来下载文件"
    exit 1
fi

# 检查Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker 未安装，请先安装 Docker"
    print_info "安装指南: https://docs.docker.com/get-docker/"
    exit 1
fi

print_info "正在下载并运行 DockEase..."

# 下载并直接执行
if $DOWNLOAD_CMD "$DOCKEASE_URL" | bash; then
    print_success "DockEase 运行完成"
else
    print_error "下载或运行失败"
    exit 1
fi
