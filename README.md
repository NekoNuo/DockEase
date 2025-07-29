# 🐳 DockEase

**一个强大而简单的 Docker 容器管理工具**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell Script](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Docker](https://img.shields.io/badge/Docker-Compatible-blue.svg)](https://www.docker.com/)

DockEase 是一个用纯 Shell 脚本编写的 Docker 管理工具，提供直观的交互式界面，让 Docker 容器和镜像管理变得简单高效。

## ✨ 特性

- 🚀 **零依赖**: 纯 Shell 脚本，无需安装额外软件
- 🎯 **功能完整**: 涵盖容器和镜像的完整生命周期管理
- 🎨 **用户友好**: 彩色交互界面，直观易用
- 🔧 **配置管理**: JSON 配置文件，支持一键更新
- 🛡️ **安全可靠**: 完善的确认机制和错误处理
- 🌐 **网络安装**: 支持一键网络安装和运行

## 🚀 快速开始

### 方式1: 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/install.sh | bash
```

安装后直接使用：
```bash
dockease
```

### 方式2: 直接运行（无需安装）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/dockease.sh)
```

### 方式3: 下载到本地

```bash
curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/dockease.sh -o dockease.sh
chmod +x dockease.sh
./dockease.sh
```

## 📋 功能列表

### 🐳 容器管理
- **列出容器**: 查看所有容器状态
- **启动容器**: 选择并启动已停止的容器
- **停止容器**: 安全停止运行中的容器
- **重启容器**: 重启指定容器
- **删除容器**: 删除不需要的容器
- **快速删除**: 一键停止并删除容器

### 🖼️ 镜像管理
- **列出镜像**: 查看本地所有镜像
- **拉取镜像**: 从仓库拉取最新镜像
- **删除镜像**: 选择性删除镜像
- **清理镜像**: 自动或手动清理未使用镜像

### 🔧 配置管理
- **添加配置**: 保存容器运行配置
- **一键更新**: pull → stop → rm → run 完整流程
- **管理配置**: 编辑、删除、导入导出配置

### 🧹 系统清理
- **清理悬空镜像**: 删除 `<none>` 标签镜像
- **系统清理**: Docker 系统级清理
- **完整清理**: 清理所有未使用资源

## 🎮 使用示例

### 基本操作
```bash
# 启动 DockEase
./dockease.sh

# 选择功能（例如：3 停止容器）
# 选择要操作的容器（例如：1）
# 确认操作（y/N）
```

### 配置管理
```bash
# 添加新的容器配置
选择 "11) Add container configuration"
输入容器名称、镜像名称、运行命令

# 一键更新容器
选择 "12) One-click update"
选择已配置的容器进行更新
```

## 📁 项目结构

```
DockEase/
├── dockease.sh              # 主程序
├── install.sh               # 一键安装脚本
├── run.sh                   # 直接运行脚本
├── dockease-launcher.sh     # 智能启动器（自动更新）
├── README.md                # 项目说明
└── NETWORK_INSTALL.md       # 网络安装详细说明
```

## 🔧 系统要求

- **操作系统**: Linux, macOS, Windows (WSL)
- **Shell**: Bash 4.0+
- **Docker**: 已安装并运行
- **工具**: curl 或 wget（用于网络安装）
- **可选**: jq（用于配置管理功能）

## 📖 详细文档

- [网络安装指南](NETWORK_INSTALL.md) - 详细的网络安装和部署说明
- [功能说明](#功能列表) - 完整的功能列表和使用方法

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 🔍 故障排除

### Docker 未运行
```bash
# 启动 Docker 服务
sudo systemctl start docker

# 检查 Docker 状态
docker info
```

### 权限问题
```bash
# 将用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录或使用 newgrp
newgrp docker
```

### 网络问题
```bash
# 使用代理
export https_proxy=http://proxy:port

# 或直接下载文件
wget https://raw.githubusercontent.com/NekoNuo/DockEase/main/dockease.sh
```

## 📊 功能演示

```
═══════════════════════════════════════════════════════════════
  🐳 DockEase v1.0.0 - Docker Management Tool
═══════════════════════════════════════════════════════════════

  ⚙️ Container Management:
    1) List containers
    2) Start containers
    3) Stop containers
    4) Restart containers
    5) Remove containers
    6) Quick remove (stop + rm)

  🖼️ Image Management:
    7) List images
    8) Pull images
    9) Remove images
   10) Clean unused images

  🔧 Build Management:
   11) Add container configuration
   12) One-click update
   13) Manage configurations

  🧹 System Cleanup:
   14) Clean dangling images
   15) System prune
   16) Full cleanup

  📚 Help & Info:
   17) Help
   18) About

  🚪 Exit:
    0) Exit

Enter your choice [0-18]:
```

## 🌟 高级功能

### 配置文件格式
DockEase 使用 JSON 格式保存配置：

```json
{
  "containers": {
    "my-app": {
      "image": "nginx:latest",
      "run_cmd": "docker run -d -p 80:80 --name my-app nginx:latest",
      "description": "Web server",
      "created": "2024-01-01T00:00:00Z"
    }
  }
}
```

### 环境变量
```bash
# 自定义配置文件位置
export DOCKEASE_CONFIG="/path/to/config.json"

# 自定义日志文件位置
export DOCKEASE_LOG="/path/to/dockease.log"
```

## 🚀 企业级部署

### 内网部署
1. 下载脚本到内网服务器
2. 修改脚本中的 URL 指向内网地址
3. 通过内网分发给用户

### 批量部署
```bash
# 批量安装到多台服务器
for server in server1 server2 server3; do
    ssh $server "curl -fsSL https://your-internal-server/install.sh | bash"
done
```

## 🙏 致谢

- Docker 社区提供的优秀容器技术
- 所有贡献者和用户的支持
- Shell 脚本社区的最佳实践

## 📞 联系方式

- 提交 Issue: [GitHub Issues](https://github.com/NekoNuo/DockEase/issues)
- 功能请求: [GitHub Discussions](https://github.com/NekoNuo/DockEase/discussions)

---

**⭐ 如果这个项目对您有帮助，请给个 Star！**

**🔗 快速开始**: `curl -fsSL https://raw.githubusercontent.com/NekoNuo/DockEase/main/install.sh | bash`
