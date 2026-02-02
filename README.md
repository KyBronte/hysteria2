<div align="center">

# 🚀 Hysteria 2 一键安装脚本

[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](README_EN.md)
[![中文](https://img.shields.io/badge/语言-中文-red?style=for-the-badge)](README.md)

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg?style=flat-square)](https://github.com/apernet/hysteria)
[![Hysteria](https://img.shields.io/badge/Hysteria-2.x-purple.svg?style=flat-square)](https://hysteria.network/)

**一键部署 Hysteria 2 代理服务器**

*支持 Debian 11+ / Ubuntu 20.04+ / CentOS 7+ / 更多发行版*

</div>

---

## ✨ 功能特性

- 🚀 **一键安装** - 自动完成所有配置
- 🔐 **证书支持** - 自签名证书 / Let's Encrypt ACME
- 🔄 **在线更新** - 一键升级到最新版本
- 📱 **自动生成** - 客户端配置 + 分享链接
- 🛡️ **防火墙配置** - 自动放行端口 (UFW/firewalld/iptables)
- 📊 **日志记录** - 安装过程完整记录
- 🌍 **多系统支持** - Debian/Ubuntu/CentOS/Rocky/Alma/Arch 等

---

## 📋 系统要求

| 要求 | 说明 |
|------|------|
| **系统** | Debian 11+ / Ubuntu 20.04+ / CentOS 7+ |
| **权限** | root 用户 |
| **架构** | amd64 / arm64 / armv7 |
| **网络** | 需要公网 IP |

---

## 🚀 快速开始

### 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh)
```

### 手动安装

```bash
# 下载脚本
wget -O hy2.sh https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh

# 添加权限
chmod +x hy2.sh

# 运行
./hy2.sh
```

---

## 📖 使用方法

### 交互式菜单

```
  1. 安装 Hysteria 2
  2. 切换证书模式
  3. 修改配置
  4. 更新核心
  5. 查看配置
  6. 查看日志
  7. 卸载
  0. 退出
```

### 命令行模式

```bash
./install.sh install    # 安装
./install.sh update     # 更新核心
./install.sh modify     # 修改配置
./install.sh switch     # 切换证书模式
./install.sh config     # 查看配置
./install.sh logs       # 查看日志
./install.sh uninstall  # 卸载
```

---

## 📁 文件位置

| 文件 | 路径 |
|------|------|
| 主程序 | `/usr/local/bin/hysteria` |
| 服务端配置 | `/etc/hysteria/config.yaml` |
| 客户端配置 | `/etc/hysteria/client.yaml` |
| 证书目录 | `/etc/hysteria/certs/` |
| 安装日志 | `/var/log/hysteria-install.log` |

---

## 🔧 常用命令

```bash
# 服务管理
systemctl start hysteria-server    # 启动
systemctl stop hysteria-server     # 停止
systemctl restart hysteria-server  # 重启
systemctl status hysteria-server   # 状态

# 日志查看
journalctl -u hysteria-server -f   # 实时日志
journalctl -u hysteria-server -n 100  # 最近100条
```

---

## 📱 客户端推荐

| 平台 | 客户端 |
|------|--------|
| **Windows** | [v2rayN](https://github.com/2dust/v2rayN) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **macOS** | [V2RayXS](https://github.com/tzmax/V2RayXS) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **Linux** | [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **Android** | [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid) / [Surfboard](https://getsurfboard.com/) |
| **iOS** | [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) / [Stash](https://apps.apple.com/app/stash/id1596063349) |

---

## ⚠️ 注意事项

> [!IMPORTANT]
> 确保服务器防火墙/安全组已放行 **UDP 端口**

> [!TIP]
> 使用自签名证书时，客户端需开启 `insecure` 选项

> [!NOTE]
> ACME 证书需要域名解析到服务器 IP，且 80 端口可用

---

## 📄 开源协议

[MIT License](LICENSE)

---

## 🙏 致谢

- [Hysteria](https://github.com/apernet/hysteria) - 核心代理程序

<div align="center">
<sub>Made with ❤️</sub>
</div>
