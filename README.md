# Hysteria 2 一键安装脚本

[![English](https://img.shields.io/badge/Language-English-blue)](README_EN.md) [![中文](https://img.shields.io/badge/语言-中文-red)](README.md)

Hysteria 2 部署和管理脚本，支持 Debian 11+、Ubuntu 20.04+、CentOS 7+、AlmaLinux、Rocky Linux。

## 功能

- 交互式安装，自动处理依赖和服务配置
- TCP BBR + FQ 和 UDP 缓冲区优化
- 端口跳跃（Port Hopping），利用 iptables DNAT 转发
- Obfuscation 混淆，避免协议特征识别
- 自动生成 Clash Meta、Sing-box 和官方客户端配置文件
- 支持 GitHub 镜像源（ghproxy、fastgit）和国内系统源（清华/中科大/阿里云）
- 自签名证书或自定义证书
- 防火墙规则自动配置（UFW/firewalld/iptables）

## 系统要求

- **系统**: Debian 11+ / Ubuntu 20.04+ / CentOS 7+ / AlmaLinux / Rocky Linux
- **架构**: x86_64 / aarch64 / armv7
- **权限**: root
- **网络**: 公网 IP

## 安装

直接运行：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh)
```

或下载后执行：

```bash
wget https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh
chmod +x install.sh
./install.sh
```

## 使用

### 菜单操作

直接运行脚本进入交互菜单：

```bash
./install.sh
```

菜单功能：
- 安装 / 更新 / 卸载
- 查看配置（含分享链接和二维码）
- 修改端口、密码、SNI、混淆
- 服务管理（启动/停止/重启）
- 切换证书模式
- 查看日志和端口占用
- 中英文切换

### 命令行模式

无交互安装（用于脚本部署）：

```bash
./install.sh install \
    --port 443 \
    --password "your_password" \
    --sni "www.bing.com" \
    --obfs "obfs_pass" \
    --headless
```

其他命令：

```bash
./install.sh update      # 更新核心
./install.sh config      # 查看配置
./install.sh logs        # 实时日志
./install.sh uninstall   # 卸载
```

## 功能说明

### 端口跳跃

通过 iptables DNAT 将端口范围（如 20000-30000）转发到实际监听端口。客户端配置端口跳跃后，主端口被封时会自动尝试范围内其他端口。

安装时选择「端口跳跃模式」，或用菜单选项 8 查看当前规则。

### 网络优化

脚本自动写入 `/etc/sysctl.d/99-hysteria.conf`：

- UDP 缓冲区增大到 16MB（`net.core.rmem_max`/`wmem_max`）
- 启用 BBR 拥塞控制（`net.ipv4.tcp_congestion_control`）
- 使用 FQ 队列（`net.core.default_qdisc`）

### 客户端配置

安装完成后自动生成到 `/etc/hysteria/configs/`：

- `clash-meta.yaml` - Clash Meta / Mihomo
- `sing-box.json` - Sing-box outbound
- `hy-client.yaml` / `hy-client.json` - 官方客户端

## 文件路径

```
/usr/local/bin/hysteria              # 主程序
/etc/hysteria/config.yaml            # 服务端配置
/etc/hysteria/certs/                 # 证书和私钥
/etc/hysteria/configs/               # 客户端配置文件
/etc/sysctl.d/99-hysteria.conf       # 网络优化参数
```

## 客户端

- **Windows**: [v2rayN](https://github.com/2dust/v2rayN) + Hysteria2 Core / [NekoRay](https://github.com/MatsuriDayo/nekoray)
- **macOS**: [Sing-box](https://github.com/SagerNet/sing-box) / [NekoRay](https://github.com/MatsuriDayo/nekoray)
- **Linux**: [NekoRay](https://github.com/MatsuriDayo/nekoray) / [官方 CLI](https://github.com/apernet/hysteria)
- **Android**: [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid) / [Sing-box](https://github.com/SagerNet/sing-box)
- **iOS**: [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) / [Stash](https://apps.apple.com/app/stash/id1596063349)

---

## ⚠️ 注意事项

> [!IMPORTANT]
> **关于自自签名证书**: 脚本默认使用自签名证书 (Self-signed)。在客户端使用时，**必须**开启 `insecure` (跳过证书验证) 选项。

> [!TIP]
> **防火墙**: 脚本会自动通过 `ufw` / `firewalld` / `iptables` 放行端口。如果使用云服务商（如阿里云、AWS），请务必在网页控制台的安全组中放行对应的 **UDP 端口**。

> [!NOTE]
> **端口跳跃**: 启用端口跳跃需要内核支持 iptables/netfilter 转发，通常绝大多数 VPS 均默认支持。

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=KyBronte/hysteria2&type=Date)](https://star-history.com/#KyBronte/hysteria2&Date)

---

## 开源协议

[MIT License](LICENSE)

---

## 致谢

- [Hysteria](https://github.com/apernet/hysteria) - 核心协议
