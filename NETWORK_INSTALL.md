# 🌐 DockEase 网络安装指南

## 📋 安装方式

### 🚀 方式1: 一键安装（推荐）
将 DockEase 安装到系统，可以在任何地方使用 `dockease` 命令：

```bash
# 使用 curl
curl -fsSL https://your-domain.com/install.sh | bash

# 或使用 wget
wget -qO- https://your-domain.com/install.sh | bash
```

安装后使用：
```bash
dockease  # 启动 DockEase
```

### ⚡ 方式2: 直接运行（无需安装）
直接从网络运行，不在本地安装：

```bash
# 使用 curl
curl -fsSL https://your-domain.com/run.sh | bash

# 或使用 wget
wget -qO- https://your-domain.com/run.sh | bash

# 或者直接运行主脚本
bash <(curl -fsSL https://your-domain.com/dockease.sh)
```

### 🔄 方式3: 智能启动器（自动更新）
下载启动器，自动检查更新：

```bash
# 下载启动器
curl -fsSL https://your-domain.com/dockease-launcher.sh -o dockease-launcher.sh
chmod +x dockease-launcher.sh

# 运行（会自动检查更新）
./dockease-launcher.sh
```

启动器功能：
```bash
./dockease-launcher.sh                # 正常启动
./dockease-launcher.sh --force-update # 强制更新
./dockease-launcher.sh --clear-cache  # 清理缓存
./dockease-launcher.sh --version      # 查看版本
./dockease-launcher.sh --help         # 显示帮助
```

## 🛠️ 部署到服务器

### GitHub Pages / GitHub Raw
1. 将文件上传到 GitHub 仓库
2. 使用 GitHub Raw URL：
   ```
   https://raw.githubusercontent.com/username/repo/main/dockease.sh
   https://raw.githubusercontent.com/username/repo/main/install.sh
   https://raw.githubusercontent.com/username/repo/main/run.sh
   ```

### 自己的服务器
1. 将文件上传到 Web 服务器
2. 确保文件可以通过 HTTP/HTTPS 访问
3. 更新脚本中的 URL

### CDN 服务
- jsDelivr: `https://cdn.jsdelivr.net/gh/username/repo@main/dockease.sh`
- Statically: `https://cdn.statically.io/gh/username/repo/main/dockease.sh`

## 🔧 配置说明

### 修改下载 URL
在安装脚本中修改这行：
```bash
DOCKEASE_URL="https://your-domain.com/dockease.sh"
```

### 自定义安装路径
在 install.sh 中修改：
```bash
INSTALL_DIR="/usr/local/bin"  # 系统级安装
# 或
INSTALL_DIR="$HOME/bin"      # 用户级安装
```

## 📝 使用示例

### 快速开始
```bash
# 一键安装并运行
curl -fsSL https://your-domain.com/install.sh | bash && dockease
```

### 临时使用
```bash
# 直接运行，不安装
bash <(curl -fsSL https://your-domain.com/dockease.sh)
```

### 企业环境
```bash
# 下载到本地，检查后运行
curl -fsSL https://your-domain.com/dockease.sh -o dockease.sh
# 检查脚本内容...
chmod +x dockease.sh
./dockease.sh
```

## ⚠️ 安全注意事项

1. **验证来源**: 确保从可信的源下载脚本
2. **检查内容**: 建议先下载查看脚本内容再执行
3. **网络安全**: 使用 HTTPS 确保传输安全
4. **权限控制**: 避免不必要的 sudo 权限

## 🔍 故障排除

### 下载失败
```bash
# 检查网络连接
curl -I https://your-domain.com/dockease.sh

# 使用代理
export https_proxy=http://proxy:port
curl -fsSL https://your-domain.com/dockease.sh | bash
```

### 权限问题
```bash
# 用户级安装
mkdir -p ~/bin
curl -fsSL https://your-domain.com/dockease.sh -o ~/bin/dockease
chmod +x ~/bin/dockease
export PATH="$HOME/bin:$PATH"
```

### Docker 未安装
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh

# CentOS/RHEL
sudo yum install docker-ce

# 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker
```
