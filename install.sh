#!/bin/bash

#===============================================================================
# DockEase 一键安装脚本
# 用法: curl -fsSL https://your-domain.com/install.sh | bash
# 或者: wget -qO- https://your-domain.com/install.sh | bash
#===============================================================================

set -uo pipefail

# 配置
DOCKEASE_URL="https://raw.githubusercontent.com/NekoNuo/DockEase/main/dockease.sh"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="dockease"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 打印函数
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 检查依赖
check_dependencies() {
    print_info "检查系统依赖..."
    
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
        print_warning "Docker 未安装，请先安装 Docker"
        print_info "安装指南: https://docs.docker.com/get-docker/"
    fi
    
    print_success "依赖检查完成"
}

# 下载并安装
install_dockease() {
    print_info "正在下载 DockEase..."
    
    # 创建临时文件
    local temp_file=$(mktemp)
    
    # 下载脚本
    if $DOWNLOAD_CMD "$DOCKEASE_URL" > "$temp_file"; then
        print_success "下载完成"
    else
        print_error "下载失败，请检查网络连接"
        rm -f "$temp_file"
        exit 1
    fi
    
    # 检查是否需要sudo
    if [[ -w "$INSTALL_DIR" ]]; then
        SUDO_CMD=""
    else
        SUDO_CMD="sudo"
        print_info "需要管理员权限安装到 $INSTALL_DIR"
    fi
    
    # 安装脚本
    print_info "正在安装 DockEase 到 $INSTALL_DIR/$SCRIPT_NAME..."
    
    if $SUDO_CMD cp "$temp_file" "$INSTALL_DIR/$SCRIPT_NAME" && \
       $SUDO_CMD chmod +x "$INSTALL_DIR/$SCRIPT_NAME"; then
        print_success "安装完成！"
    else
        print_error "安装失败"
        rm -f "$temp_file"
        exit 1
    fi
    
    # 清理临时文件
    rm -f "$temp_file"
}

# 显示使用说明
show_usage() {
    echo
    echo "🎉 DockEase 安装成功！"
    echo
    echo "使用方法："
    echo "  $SCRIPT_NAME          # 启动 DockEase"
    echo "  $SCRIPT_NAME --help   # 显示帮助"
    echo
    echo "如果命令不存在，请确保 $INSTALL_DIR 在您的 PATH 中"
    echo "或者使用完整路径: $INSTALL_DIR/$SCRIPT_NAME"
    echo
}

# 主函数
main() {
    echo "🐳 DockEase 一键安装脚本"
    echo "=========================="
    echo
    
    check_dependencies
    install_dockease
    show_usage
    
    print_success "安装完成！现在可以运行 '$SCRIPT_NAME' 开始使用"
}

# 执行主函数
main "$@"
