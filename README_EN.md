<div align="center">

# 🚀 Hysteria 2 One-Click Installer

[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](README_EN.md)
[![中文](https://img.shields.io/badge/语言-中文-red?style=for-the-badge)](README.md)

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg?style=flat-square)](https://github.com/apernet/hysteria)
[![Hysteria](https://img.shields.io/badge/Hysteria-2.x-purple.svg?style=flat-square)](https://hysteria.network/)

**Deployment & Management Script for Hysteria 2 Proxy**

*Supports Debian 11+ / Ubuntu 20.04+ / CentOS 7+ / AlmaLinux / Rocky Linux*

</div>

---

## ✨ Features

- 🚀 **One-Click Install** - Auto-install dependencies, setup core and service
- ⚡ **Network Optimization** - Auto-configure TCP BBR + FQ and UDP buffer (sysctl)
- 🦗 **Port Hopping** - Support Port Hopping (via iptables/DNAT) to resist blocking
- 🛡️ **Security** - Support Obfuscation passwords to prevent protocol detection
- 📱 **Multi-Client Config** - Auto-generate configs for **Clash Meta**, **Sing-box** and official client
- 🌍 **Mirror Support** - Integrated GitHub mirrors (ghproxy etc.) for fast download in China
- 🔒 **Cert Mode** - Support Self-signed Certificate or Custom Certificate
- 📊 **Port Check** - Smart port detection & Auto firewall configuration (UFW/firewalld/iptables)

---

## 📋 Requirements

| Requirement | Description |
|-------------|-------------|
| **OS** | Debian 11+ / Ubuntu 20.04+ / CentOS 7+ |
| **Privilege** | Root access |
| **Architecture** | amd64 / arm64 / armv7 |
| **Network** | Public IP required |

---

## 🚀 Quick Start

### One-Click Install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh)
```

### Manual Install

```bash
# Download script
wget -O hy2.sh https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh

# Make executable
chmod +x hy2.sh

# Run
./hy2.sh
```

---

## 📖 Usage

### Interactive Menu

Run the script without arguments to open the menu:

```text
  1. Install Hysteria 2
  2. View Config (Share Link / QR Code)
  3. Modify Config (Port/Password/SNI/Obfs)
  4. Service Management (Start/Stop/Restart)
  5. Switch Cert Mode
  6. Update Core
  7. View Logs
  8. View Port Usage (Check port conflicts/hopping rules)
  9. Change to Chinese
  10. Uninstall
  0. Exit
```

### Command Line Mode

The script supports headless mode for batch deployment:

```bash
# Full installation example
./install.sh install \
    --port 443 \
    --password "mypassword" \
    --sni "www.bing.com" \
    --obfs "obfs_password" \
    --headless

# Common commands
./install.sh update     # Update core
./install.sh config     # View config info
./install.sh logs       # View runtime logs
./install.sh uninstall  # Uninstall
```

---

## 💡 Advanced Features

### 🦗 Port Hopping
The script supports **Port Hopping**. It uses iptables DNAT rules to forward traffic from a port range (e.g., 20000-30000) to the Hysteria 2 listening port.
- **Benefit**: Significantly improves connection survival rate when the main port is blocked by firewalls.
- **Setup**: Select "Port Hopping" mode during installation or check active rules after install.

### ⚡ Network Optimization
The installer automatically applies the following optimizations to `/etc/sysctl.d/99-hysteria.conf`:
- `net.core.rmem_max` / `net.core.wmem_max`: Increase UDP buffer to 16MB.
- `net.ipv4.tcp_congestion_control`: Enable **BBR**.
- `net.core.default_qdisc`: Enable **FQ**.

### 📱 Auto-Generate Client Configs
After installation, client configurations are generated in `/etc/hysteria/configs/`:
- `clash-meta.yaml`: Config for Clash Meta (Mihomo).
- `sing-box.json`: Outbound config for Sing-box.
- `hy-client.yaml` / `hy-client.json`: Official client configs.

---

## 📁 File Locations

| File | Path |
|------|------|
| Binary | `/usr/local/bin/hysteria` |
| Server Config | `/etc/hysteria/config.yaml` |
| Cert/Key | `/etc/hysteria/certs/` |
| **Client Configs** | `/etc/hysteria/configs/` |
| Sysctl Params | `/etc/sysctl.d/99-hysteria.conf` |

---

## 📱 Recommended Clients

| Platform | Client |
|----------|--------|
| **Windows** | [v2rayN](https://github.com/2dust/v2rayN) (requires Hysteria2 Core) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **macOS** | [Sing-box](https://github.com/SagerNet/sing-box) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **Linux** | [NekoRay](https://github.com/MatsuriDayo/nekoray) / [Hysteria Official](https://github.com/apernet/hysteria) |
| **Android** | [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid) / [Sing-box](https://github.com/SagerNet/sing-box) |
| **iOS** | [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) / [Stash](https://apps.apple.com/app/stash/id1596063349) |

---

## ⚠️ Notes

> [!IMPORTANT]
> **Self-Signed Cert**: The script defaults to using a Self-Signed Certificate. You **MUST** enable `insecure` (Skip Certificate Verification) in your client options.

> [!TIP]
> **Firewall**: The script automatically opens ports in `ufw` / `firewalld` / `iptables`. If using a Cloud Provider (AWS, Alibaba Cloud, etc.), ensure the **UDP Port** is allowed in the Security Group console.

> [!NOTE]
> **Port Hopping**: Requires kernel support for iptables/netfilter, which is available on almost all VPS.

---

## 📄 License

[MIT License](LICENSE)

---

## 🙏 Credits

- [Hysteria](https://github.com/apernet/hysteria) - Core Protocol

<div align="center">
<sub>Made with ❤️ by KyBronte</sub>
</div>
