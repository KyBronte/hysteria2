# Hysteria 2 One-Click Installer

[![English](https://img.shields.io/badge/Language-English-blue)](README_EN.md) [![中文](https://img.shields.io/badge/语言-中文-red)](README.md)

Deployment and management script for Hysteria 2. Supports Debian 11+, Ubuntu 20.04+, CentOS 7+, AlmaLinux, Rocky Linux.

## Features

- Interactive installer with dependency and service automation
- TCP BBR + FQ and UDP buffer optimization
- Port Hopping via iptables DNAT forwarding
- Obfuscation to avoid protocol fingerprinting
- Auto-generate Clash Meta, Sing-box and official client configs
- GitHub mirrors (ghproxy, fastgit) and China system mirrors (Tsinghua/USTC/Aliyun)
- Self-signed or custom certificate
- Automatic firewall rules (UFW/firewalld/iptables)

## Requirements

- **OS**: Debian 11+ / Ubuntu 20.04+ / CentOS 7+ / AlmaLinux / Rocky Linux
- **Architecture**: x86_64 / aarch64 / armv7
- **Privilege**: root
- **Network**: Public IP

## Installation

Run directly:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh)
```

Or download first:

```bash
wget https://raw.githubusercontent.com/KyBronte/hysteria2/main/install.sh
chmod +x install.sh
./install.sh
```

## Usage

### Menu Mode

Run the script to enter interactive menu:

```bash
./install.sh
```

Menu options:
- Install / Update / Uninstall
- View config (with share link and QR code)
- Modify port, password, SNI, obfuscation
- Service management (start/stop/restart)
- Switch certificate mode
- View logs and port usage
- Language toggle

### Command Line Mode

Headless installation for automation:

```bash
./install.sh install \
    --port 443 \
    --password "your_password" \
    --sni "www.bing.com" \
    --obfs "obfs_pass" \
    --headless
```

Other commands:

```bash
./install.sh update      # Update core
./install.sh config      # View config
./install.sh logs        # Live logs
./install.sh uninstall   # Uninstall
```

## Feature Details

### Port Hopping

Uses iptables DNAT to forward a port range (e.g., 20000-30000) to the actual listening port. Clients configured with port hopping will try alternative ports when the primary one is blocked.

Enable during installation by selecting "Port Hopping" mode, or check rules via menu option 8.

### Network Optimization

Script writes to `/etc/sysctl.d/99-hysteria.conf`:

- UDP buffer increased to 16MB (`net.core.rmem_max`/`wmem_max`)
- BBR congestion control enabled (`net.ipv4.tcp_congestion_control`)
- FQ queueing discipline (`net.core.default_qdisc`)

### Client Configs

Auto-generated in `/etc/hysteria/configs/`:

- `clash-meta.yaml` - Clash Meta / Mihomo
- `sing-box.json` - Sing-box outbound
- `hy-client.yaml` / `hy-client.json` - Official client

## File Paths

```
/usr/local/bin/hysteria              # Binary
/etc/hysteria/config.yaml            # Server config
/etc/hysteria/certs/                 # Certificates
/etc/hysteria/configs/               # Client configs
/etc/sysctl.d/99-hysteria.conf       # Network optimizations
```

## Clients

- **Windows**: [v2rayN](https://github.com/2dust/v2rayN) + Hysteria2 Core / [NekoRay](https://github.com/MatsuriDayo/nekoray)
- **macOS**: [Sing-box](https://github.com/SagerNet/sing-box) / [NekoRay](https://github.com/MatsuriDayo/nekoray)
- **Linux**: [NekoRay](https://github.com/MatsuriDayo/nekoray) / [Official CLI](https://github.com/apernet/hysteria)
- **Android**: [NekoBox](https://github.com/MatsuriDayo/NekoBoxForAndroid) / [Sing-box](https://github.com/SagerNet/sing-box)
- **iOS**: [Shadowrocket](https://apps.apple.com/app/shadowrocket/id932747118) / [Stash](https://apps.apple.com/app/stash/id1596063349)

## Notes

**Self-Signed Certificate**: Default mode. Enable `insecure` (skip certificate verification) in your client.

**Firewall**: Script handles UFW/firewalld/iptables automatically. For cloud providers (AWS, Alibaba, etc.), manually allow the UDP port in security group settings.

**Port Hopping**: Requires iptables/netfilter support (available on most VPS).

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=KyBronte/hysteria2&type=Date)](https://star-history.com/#KyBronte/hysteria2&Date)

---

## License

[MIT](LICENSE)
