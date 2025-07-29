#!/bin/bash

#===============================================================================
# DockEase 安装测试脚本
# 用于验证网络安装是否正常工作
#===============================================================================

set -uo pipefail

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 测试 URL 可访问性
test_url() {
    local url=$1
    local name=$2
    
    print_info "测试 $name..."
    
    if command -v curl &> /dev/null; then
        if curl -fsSL --head "$url" &> /dev/null; then
            print_success "$name 可访问"
            return 0
        else
            print_error "$name 不可访问"
            return 1
        fi
    elif command -v wget &> /dev/null; then
        if wget --spider "$url" &> /dev/null; then
            print_success "$name 可访问"
            return 0
        else
            print_error "$name 不可访问"
            return 1
        fi
    else
        print_warning "无法测试 $name（缺少 curl 或 wget）"
        return 1
    fi
}

# 测试脚本内容
test_script_content() {
    local url=$1
    local name=$2
    
    print_info "测试 $name 内容..."
    
    local content
    if command -v curl &> /dev/null; then
        content=$(curl -fsSL "$url" 2>/dev/null)
    elif command -v wget &> /dev/null; then
        content=$(wget -qO- "$url" 2>/dev/null)
    else
        print_warning "无法测试 $name 内容"
        return 1
    fi
    
    if [[ -n "$content" ]] && echo "$content" | head -1 | grep -q "#!/bin/bash"; then
        print_success "$name 内容有效"
        return 0
    else
        print_error "$name 内容无效"
        return 1
    fi
}

# 主测试函数
main() {
    echo "🧪 DockEase 网络安装测试"
    echo "========================"
    echo
    
    local base_url="https://raw.githubusercontent.com/NekoNuo/DockEase/refs/heads/main"
    local failed=0
    
    # 测试主脚本
    if ! test_url "$base_url/dockease.sh" "主脚本"; then
        ((failed++))
    elif ! test_script_content "$base_url/dockease.sh" "主脚本"; then
        ((failed++))
    fi
    
    # 测试安装脚本
    if ! test_url "$base_url/install.sh" "安装脚本"; then
        ((failed++))
    elif ! test_script_content "$base_url/install.sh" "安装脚本"; then
        ((failed++))
    fi
    
    # 测试运行脚本
    if ! test_url "$base_url/run.sh" "运行脚本"; then
        ((failed++))
    elif ! test_script_content "$base_url/run.sh" "运行脚本"; then
        ((failed++))
    fi
    
    # 测试启动器
    if ! test_url "$base_url/dockease-launcher.sh" "启动器"; then
        ((failed++))
    elif ! test_script_content "$base_url/dockease-launcher.sh" "启动器"; then
        ((failed++))
    fi
    
    echo
    echo "========================"
    
    if [[ $failed -eq 0 ]]; then
        print_success "所有测试通过！网络安装应该正常工作"
        echo
        echo "🚀 现在可以使用以下命令安装 DockEase："
        echo "curl -fsSL $base_url/install.sh | bash"
    else
        print_error "有 $failed 个测试失败"
        echo
        echo "请检查："
        echo "1. 网络连接是否正常"
        echo "2. GitHub 是否可访问"
        echo "3. 文件是否已正确上传到仓库"
    fi
}

# 执行测试
main "$@"
