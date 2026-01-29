<div align="center">

# 🚀 Hysteria 2 One-Click Installer

[![English](https://img.shields.io/badge/Language-English-blue?style=for-the-badge)](README_EN.md)
[![中文](https://img.shields.io/badge/语言-中文-red?style=for-the-badge)](README.md)

[![GitHub License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg?style=flat-square)](https://github.com/apernet/hysteria)
[![Hysteria](https://img.shields.io/badge/Hysteria-2.x-purple.svg?style=flat-square)](https://hysteria.network/)

**Deploy Hysteria 2 Proxy Server in One Click**

*Supports Debian 11+ / Ubuntu 20.04+ / CentOS 7+ / More Distros*

</div>

---

## ✨ Features

- 🚀 **One-Click Install** - Automatic configuration
- 🔐 **Certificate Support** - Self-signed / Let's Encrypt ACME
- 🔄 **Online Update** - Upgrade to latest version instantly
- 📱 **Auto Generate** - Client config + Share link
- 🛡️ **Firewall Config** - Auto allow ports (UFW/firewalld/iptables)
- 📊 **Logging** - Complete installation logs
- 🌍 **Multi-Distro** - Debian/Ubuntu/CentOS/Rocky/Alma/Arch etc.

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

# Add permission
chmod +x hy2.sh

# Run
./hy2.sh
```

---

## 📖 Usage

### Interactive Menu

```
    ╦ ╦╦ ╦╔═╗╔╦╗╔═╗╦═╗╦╔═╗  ╔═╗
    ╠═╣╚╦╝╚═╗ ║ ║╣ ╠╦╝║╠═╣  ╔═╝
    ╩ ╩ ╩ ╚═╝ ╩ ╚═╝╩╚═╩╩ ╩  ╚═╝

  1. Install Hysteria 2 (Self-signed Cert)
  2. Install Hysteria 2 (ACME Cert)
  3. Show Config
  4. Update Hysteria 2
  5. Restart Service
  6. Service Status
  7. View Logs
  8. Uninstall Hysteria 2
  0. Exit
```

### Command Line Mode

```bash
./install.sh install       # Install (self-signed)
./install.sh install-acme  # Install (ACME cert)
./install.sh update        # Update
./install.sh config        # Show config
./install.sh status        # Service status
./install.sh restart       # Restart service
./install.sh logs          # View logs
./install.sh uninstall     # Uninstall
```

---

## 📁 File Locations

| File | Path |
|------|------|
| Binary | `/usr/local/bin/hysteria` |
| Server Config | `/etc/hysteria/config.yaml` |
| Client Config | `/etc/hysteria/client.yaml` |
| Certificates | `/etc/hysteria/certs/` |
| Install Log | `/var/log/hysteria-install.log` |

---

## 🔧 Common Commands

```bash
# Service Management
systemctl start hysteria-server    # Start
systemctl stop hysteria-server     # Stop
systemctl restart hysteria-server  # Restart
systemctl status hysteria-server   # Status

# View Logs
journalctl -u hysteria-server -f      # Real-time logs
journalctl -u hysteria-server -n 100  # Last 100 lines
```

---

## 📱 Recommended Clients

| Platform | Client |
|----------|--------|
| **Windows** | [v2rayN](https://github.com/2dust/v2rayN) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **macOS** | [V2RayXS](https://github.com/tzmax/V2RayXS) / [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **Linux** | [NekoRay](https://github.com/MatsuriDayo/nekoray) |
| **Android** | [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid) / [Surfboard](https://getsurfboard.com/) |
| **iOS** | [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) / [Stash](https://apps.apple.com/app/stash/id1596063349) |

---

## ⚠️ Notes

> [!IMPORTANT]
> Make sure your server firewall/security group allows the **UDP port**

> [!TIP]
> When using self-signed certificate, enable `insecure` option in client

> [!NOTE]
> ACME certificate requires domain pointing to server IP with port 80 available

---

## 📄 License

[MIT License](LICENSE)

---

## 🙏 Credits

- [Hysteria](https://github.com/apernet/hysteria) - Core proxy program

<div align="center">
<sub>Made with ❤️</sub>
</div>
