#!/bin/bash

#===============================================================================
# DockEase 启动器 - 自动更新版本
# 用法: ./dockease-launcher.sh
#===============================================================================

set -uo pipefail

# 配置
DOCKEASE_URL="https://raw.githubusercontent.com/NekoNuo/DockEase/main/dockease.sh"
CACHE_DIR="$HOME/.cache/dockease"
CACHE_FILE="$CACHE_DIR/dockease.sh"
UPDATE_CHECK_FILE="$CACHE_DIR/last_update"
UPDATE_INTERVAL=3600  # 1小时检查一次更新

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 创建缓存目录
mkdir -p "$CACHE_DIR"

# 检查是否需要更新
need_update() {
    # 如果缓存文件不存在，需要下载
    if [[ ! -f "$CACHE_FILE" ]]; then
        return 0
    fi
    
    # 如果更新检查文件不存在，需要检查
    if [[ ! -f "$UPDATE_CHECK_FILE" ]]; then
        return 0
    fi
    
    # 检查上次更新时间
    local last_update=$(cat "$UPDATE_CHECK_FILE" 2>/dev/null || echo "0")
    local current_time=$(date +%s)
    local time_diff=$((current_time - last_update))
    
    if [[ $time_diff -gt $UPDATE_INTERVAL ]]; then
        return 0
    fi
    
    return 1
}

# 下载最新版本
download_latest() {
    print_info "正在检查 DockEase 更新..."
    
    # 检查下载工具
    if command -v curl &> /dev/null; then
        DOWNLOAD_CMD="curl -fsSL"
    elif command -v wget &> /dev/null; then
        DOWNLOAD_CMD="wget -qO-"
    else
        print_warning "无法检查更新：需要 curl 或 wget"
        return 1
    fi
    
    # 下载到临时文件
    local temp_file=$(mktemp)
    
    if $DOWNLOAD_CMD "$DOCKEASE_URL" > "$temp_file"; then
        # 检查下载的文件是否有效
        if [[ -s "$temp_file" ]] && head -1 "$temp_file" | grep -q "#!/bin/bash"; then
            mv "$temp_file" "$CACHE_FILE"
            chmod +x "$CACHE_FILE"
            echo "$(date +%s)" > "$UPDATE_CHECK_FILE"
            print_success "DockEase 已更新到最新版本"
        else
            print_warning "下载的文件无效，使用缓存版本"
            rm -f "$temp_file"
            return 1
        fi
    else
        print_warning "无法下载更新，使用缓存版本"
        rm -f "$temp_file"
        return 1
    fi
}

# 运行 DockEase
run_dockease() {
    if [[ -f "$CACHE_FILE" ]]; then
        print_info "启动 DockEase..."
        bash "$CACHE_FILE" "$@"
    else
        print_warning "DockEase 缓存文件不存在，请检查网络连接"
        exit 1
    fi
}

# 主函数
main() {
    # 检查是否需要更新
    if need_update; then
        download_latest
    fi
    
    # 运行 DockEase
    run_dockease "$@"
}

# 处理参数
case "${1:-}" in
    --force-update)
        print_info "强制更新 DockEase..."
        rm -f "$UPDATE_CHECK_FILE"
        download_latest
        ;;
    --clear-cache)
        print_info "清理 DockEase 缓存..."
        rm -rf "$CACHE_DIR"
        print_success "缓存已清理"
        ;;
    --version)
        if [[ -f "$CACHE_FILE" ]]; then
            grep "readonly SCRIPT_VERSION" "$CACHE_FILE" | cut -d'"' -f2
        else
            echo "未安装"
        fi
        ;;
    --help)
        echo "DockEase 启动器"
        echo
        echo "用法: $0 [选项]"
        echo
        echo "选项:"
        echo "  --force-update  强制更新到最新版本"
        echo "  --clear-cache   清理本地缓存"
        echo "  --version       显示版本信息"
        echo "  --help          显示此帮助信息"
        echo
        ;;
    *)
        main "$@"
        ;;
esac
