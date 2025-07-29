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

# 检查是否已安装
check_existing_installation() {
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        return 0  # 已安装
    else
        return 1  # 未安装
    fi
}

# 获取当前版本
get_current_version() {
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        local version=$(grep "^SCRIPT_VERSION=" "$INSTALL_DIR/$SCRIPT_NAME" 2>/dev/null | head -1 | cut -d'"' -f2)
        if [[ -n "$version" ]]; then
            echo "$version"
        else
            # 兼容旧版本，尝试从注释中获取版本信息
            local old_version=$(grep -i "version\|v[0-9]" "$INSTALL_DIR/$SCRIPT_NAME" | head -1 | grep -o "v\?[0-9]\+\.[0-9]\+\.[0-9]\+" | head -1)
            if [[ -n "$old_version" ]]; then
                echo "$old_version"
            else
                echo "legacy"  # 标记为旧版本
            fi
        fi
    else
        echo ""
    fi
}

# 获取远程版本
get_remote_version() {
    local temp_file=$(mktemp)
    if $DOWNLOAD_CMD "$DOCKEASE_URL" > "$temp_file" 2>/dev/null; then
        grep "^SCRIPT_VERSION=" "$temp_file" | head -1 | cut -d'"' -f2
        rm -f "$temp_file"
    else
        rm -f "$temp_file"
        echo ""
    fi
}

# 更新现有安装
update_dockease() {
    print_info "正在更新 DockEase..."

    local current_version=$(get_current_version)
    local remote_version=$(get_remote_version)

    if [[ -z "$remote_version" ]]; then
        print_error "无法获取远程版本信息"
        return 1
    fi

    # 处理版本显示
    local current_display="$current_version"
    if [[ -z "$current_version" ]]; then
        current_display="未知"
    elif [[ "$current_version" == "legacy" ]]; then
        current_display="旧版本"
    fi

    print_info "当前版本: $current_display"
    print_info "最新版本: $remote_version"

    # 如果是旧版本或无法确定版本，强制更新
    if [[ "$current_version" == "$remote_version" ]]; then
        print_success "您已经在使用最新版本！"
        return 0
    elif [[ "$current_version" == "legacy" ]] || [[ -z "$current_version" ]]; then
        print_warning "检测到旧版本，建议更新到最新版本"
    fi

    # 备份当前版本
    local backup_path="$INSTALL_DIR/${SCRIPT_NAME}.backup.$(date +%Y%m%d_%H%M%S)"
    if [[ -f "$INSTALL_DIR/$SCRIPT_NAME" ]]; then
        print_info "备份当前版本到: $backup_path"
        if ! $SUDO_CMD cp "$INSTALL_DIR/$SCRIPT_NAME" "$backup_path"; then
            print_warning "备份失败，继续更新..."
        fi
    fi

    # 执行更新
    install_dockease

    print_success "更新完成！从 $current_version 更新到 $remote_version"
}

# 主函数
main() {
    # 解析命令行参数
    local action="install"
    case "${1:-}" in
        --update|-u)
            action="update"
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        --version|-v)
            show_version
            exit 0
            ;;
    esac

    if [[ "$action" == "update" ]]; then
        echo "🔄 DockEase 更新脚本"
        echo "===================="
        echo

        if ! check_existing_installation; then
            print_error "未找到现有安装，请先运行安装"
            echo "运行: curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/install.sh | bash"
            exit 1
        fi

        check_dependencies
        update_dockease
    else
        echo "🐳 DockEase 一键安装脚本"
        echo "=========================="
        echo

        if check_existing_installation; then
            local current_version=$(get_current_version)
            local current_display="$current_version"
            if [[ -z "$current_version" ]]; then
                current_display="未知"
            elif [[ "$current_version" == "legacy" ]]; then
                current_display="旧版本"
            fi

            print_warning "检测到已安装的 DockEase (版本: $current_display)"

            # 如果是旧版本，强烈建议更新
            if [[ "$current_version" == "legacy" ]] || [[ -z "$current_version" ]]; then
                print_info "检测到旧版本，强烈建议更新以获得最新功能"
                echo -n "是否要更新到最新版本？(Y/n): "
            else
                echo -n "是否要更新到最新版本？(y/N): "
            fi

            read -r update_confirm

            # 对于旧版本，默认为更新
            if [[ "$current_version" == "legacy" ]] || [[ -z "$current_version" ]]; then
                if [[ ! "$update_confirm" =~ ^[Nn]$ ]]; then
                    check_dependencies
                    update_dockease
                    exit 0
                fi
            else
                if [[ "$update_confirm" =~ ^[Yy]$ ]]; then
                    check_dependencies
                    update_dockease
                    exit 0
                fi
            fi

            print_info "保持当前版本"
            exit 0
        fi

        check_dependencies
        install_dockease
        show_usage

        print_success "安装完成！现在可以运行 '$SCRIPT_NAME' 开始使用"
    fi
}

# 显示帮助信息
show_help() {
    echo "DockEase 安装/更新脚本"
    echo
    echo "用法:"
    echo "  curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/install.sh | bash"
    echo "  curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/install.sh | bash -s -- --update"
    echo
    echo "选项:"
    echo "  --update, -u    更新现有安装"
    echo "  --help, -h      显示此帮助信息"
    echo "  --version, -v   显示版本信息"
    echo
    echo "示例:"
    echo "  # 安装 DockEase"
    echo "  curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/install.sh | bash"
    echo
    echo "  # 更新 DockEase"
    echo "  curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/install.sh | bash -s -- --update"
}

# 显示版本信息
show_version() {
    echo "DockEase 安装脚本 v1.2.0"
    echo "项目地址: https://github.com/NekoNuo/DockEase"
}

# 执行主函数
main "$@"
