<div align="center">

# 🚀 Hysteria 2 一键安装脚本

[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](README_EN.md)
[![中文](https://img.shields.io/badge/语言-中文-red?style=for-the-badge)](README.md)

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg?style=flat-square)](https://github.com/apernet/hysteria)
[![Hysteria](https://img.shields.io/badge/Hysteria-2.x-purple.svg?style=flat-square)](https://hysteria.network/)

**Hysteria 2 协议全能管理脚本**

*支持 Debian 11+ / Ubuntu 20.04+ / CentOS 7+ / AlmaLinux / Rocky Linux*

</div>

---

## ✨ 功能特性

- 🚀 **一键安装** - 自动完成依赖安装、环境配置与服务启动
- ⚡ **网络优化** - 自动配置 TCP BBR + FQ 及 UDP 缓冲区 (sysctl) 优化
- 🦗 **端口跳跃** - 支持 Port Hopping (利用 iptables/DNAT)，增强抗封锁能力
- 🛡️ **安全增强** - 支持 Obfuscation (混淆) 密码，防止协议被精确识别
- 📱 **多客户端支持** - 自动生成 **Clash Meta**, **Sing-box** 及 Hy2 官方客户端配置
- 🌍 **国内镜像源** - 集成 ghproxy、清华/中科大/阿里云源，国内服务器安装无忧
- 🔒 **证书管理** - 支持自签名证书 (Self-signed) 或 自有证书 (Custom)
- 📊 **端口检测** - 智能识别端口占用，自动配置防火墙 (UFW/firewalld/iptables)

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

运行脚本后无需参数即可进入菜单：

```text
  1. 安装 Hysteria 2
  2. 查看配置 (包含分享链接/二维码)
  3. 修改配置 (端口/密码/SNI/混淆)
  4. 服务管理 (启动/停止/重启)
  5. 切换证书模式
  6. 更新核心
  7. 查看日志
  8. 查看端口占用 (排查端口冲突/跳跃规则)
  9. 切换语言 (Change to English)
  10. 卸载
  0. 退出
```

### 命令行参数

脚本支持无交互模式 (Headless)，适合批量部署：

```bash
# 完整参数安装示例
./install.sh install \
    --port 443 \
    --password "mypassword" \
    --sni "www.bing.com" \
    --obfs "obfs_password" \
    --headless

# 常用命令
./install.sh update     # 更新核心
./install.sh config     # 查看配置信息
./install.sh logs       # 查看运行日志
./install.sh uninstall  # 卸载
```

---

## 💡 高级功能说明

### 🦗 端口跳跃 (Port Hopping)
脚本支持配置 **端口跳跃**，通过 iptables DNAT 规则，将一个端口范围（例如 20000-30000）的流量转发到 Hysteria 2 的监听端口。
- **作用**: 当主端口被防火墙阻断时，客户端会自动尝试跳跃范围内的其他端口，极大提高存活率。
- **配置**: 在安装过程中选择 "端口跳跃" 模式，或安装后查看相关规则。

### ⚡ 网络参数优化
安装过程中会自动应用以下优化参数至 `/etc/sysctl.d/99-hysteria.conf`：
- `net.core.rmem_max` / `net.core.wmem_max`: 调大 UDP 缓冲区至 16MB，防止丢包。
- `net.ipv4.tcp_congestion_control`: 启用 **BBR**。
- `net.core.default_qdisc`: 启用 **FQ**。

### 📱 客户端配置自动生成
安装完成后，脚本会自动生成以下文件至 `/etc/hysteria/configs/`：
- `clash-meta.yaml`: 适配 Clash Meta (Mihomo) 的配置文件。
- `sing-box.json`: 适配 Sing-box 的 outbound 配置。
- `hy-client.yaml` / `hy-client.json`: 官方客户端配置。

---

## 📁 文件位置

| 文件 | 路径 |
|------|------|
| 主程序 | `/usr/local/bin/hysteria` |
| 服务端配置 | `/etc/hysteria/config.yaml` |
| 证书/私钥 | `/etc/hysteria/certs/` |
| **客户端配置** | `/etc/hysteria/configs/` |
| 端口优化参数 | `/etc/sysctl.d/99-hysteria.conf` |

---

## 📱 客户端推荐

| 平台 | 客户端 |
|------|--------|
| **Windows** | [v2rayN](https://github.com/2dust/v2rayN) (需下载 Hysteria2 Core) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **macOS** | [Sing-box](https://github.com/SagerNet/sing-box) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **Linux** | [NekoRay](https://github.com/MatsuriDayo/nekoray) / [Hysteria 官方](https://github.com/apernet/hysteria) |
| **Android** | [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid) / [Sing-box](https://github.com/SagerNet/sing-box) |
| **iOS** | [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) / [Stash](https://apps.apple.com/app/stash/id1596063349) |

---

## ⚠️ 注意事项

> [!IMPORTANT]
> **关于自自签名证书**: 脚本默认使用自签名证书 (Self-signed)。在客户端使用时，**必须**开启 `insecure` (跳过证书验证) 选项。

> [!TIP]
> **防火墙**: 脚本会自动通过 `ufw` / `firewalld` / `iptables` 放行端口。如果使用云服务商（如阿里云、AWS），请务必在网页控制台的安全组中放行对应的 **UDP 端口**。

> [!NOTE]
> **端口跳跃**: 启用端口跳跃需要内核支持 iptables/netfilter 转发，通常绝大多数 VPS 均默认支持。

---

## 📄 开源协议

[MIT License](LICENSE)

---

## 🙏 致谢

- [Hysteria](https://github.com/apernet/hysteria) - 核心协议

<div align="center">
<sub>Made with ❤️ by KyBronte</sub>
</div>
