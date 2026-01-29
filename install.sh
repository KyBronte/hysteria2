#!/bin/bash
# Hysteria 2 极简安装脚本 | Lightweight Hysteria 2 Installer
# 支持 | Support: Debian 11+ / Ubuntu 20.04+ / CentOS 7+
# GitHub: https://github.com/KyBronte/hysteria2

set -e
export LANG=en_US.UTF-8

# 颜色定义
R='\033[0;31m' G='\033[0;32m' Y='\033[1;33m' C='\033[0;36m' P='\033[0m'

# Root检查
[[ $EUID -ne 0 ]] && { echo -e "${R}请使用 root 运行${P}"; exit 1; }

# 系统检测
detect_sys() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
    else
        echo -e "${R}不支持的系统${P}"; exit 1
    fi
    
    case $(uname -m) in
        x86_64|amd64) ARCH=amd64 ;;
        aarch64|arm64) ARCH=arm64 ;;
        armv7*) ARCH=armv7 ;;
        *) echo -e "${R}不支持的架构${P}"; exit 1 ;;
    esac
}

# 获取公网IP
get_ip() {
    IP=$(curl -s4 --max-time 3 ip.sb || curl -s4 --max-time 3 ifconfig.me || echo "")
    [[ -z "$IP" ]] && IP=$(curl -s6 --max-time 3 ip.sb || echo "127.0.0.1")
}

# 生成随机值
rand() {
    PORT=$((RANDOM % 40000 + 10000))
    while ss -tuln | grep -q ":$PORT "; do PORT=$((RANDOM % 40000 + 10000)); done
    PASS=$(openssl rand -base64 18 | tr -d '/+=' | head -c 16)
}

# 安装依赖
install_deps() {
    echo -e "${C}安装依赖...${P}"
    case $OS in
        debian|ubuntu) apt update -qq && apt install -y -qq curl wget openssl jq >/dev/null 2>&1 ;;
        centos|rhel|rocky|almalinux) yum install -y -q curl wget openssl jq >/dev/null 2>&1 ;;
        *) echo -e "${Y}未知系统，跳过依赖安装${P}" ;;
    esac
}

# 下载Hysteria 2
download_hy2() {
    echo -e "${C}下载 Hysteria 2...${P}"
    VERSION=$(curl -s "https://api.github.com/repos/apernet/hysteria/releases/latest" | jq -r '.tag_name' || echo "app/v2.6.1")
    URL="https://github.com/apernet/hysteria/releases/download/${VERSION}/hysteria-linux-${ARCH}"
    
    curl -Lo /usr/local/bin/hysteria "$URL" && chmod +x /usr/local/bin/hysteria || { echo -e "${R}下载失败${P}"; exit 1; }
    echo -e "${G}✓ Hysteria 2 安装完成${P}"
}

# 生成证书
gen_cert() {
    mkdir -p /etc/hysteria /etc/hysteria/certs
    openssl ecparam -genkey -name prime256v1 -out /etc/hysteria/certs/server.key 2>/dev/null
    openssl req -new -x509 -days 36500 -key /etc/hysteria/certs/server.key \
        -out /etc/hysteria/certs/server.crt -subj "/CN=bing.com" 2>/dev/null
    chmod 600 /etc/hysteria/certs/server.key
}

# 创建配置
create_config() {
    cat > /etc/hysteria/config.yaml << EOF
listen: :${PORT}
tls:
  cert: /etc/hysteria/certs/server.crt
  key: /etc/hysteria/certs/server.key
auth:
  type: password
  password: "${PASS}"
masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
bandwidth:
  up: 1 gbps
  down: 1 gbps
EOF
    chmod 600 /etc/hysteria/config.yaml
}

# 创建systemd服务
create_service() {
    cat > /etc/systemd/system/hysteria-server.service << EOF
[Unit]
Description=Hysteria 2 Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria/config.yaml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    systemctl enable hysteria-server --now >/dev/null 2>&1
}

# 配置防火墙
config_fw() {
    command -v ufw >/dev/null 2>&1 && ufw allow ${PORT}/udp >/dev/null 2>&1
    command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --permanent --add-port=${PORT}/udp >/dev/null 2>&1 && firewall-cmd --reload >/dev/null 2>&1
    iptables -C INPUT -p udp --dport $PORT -j ACCEPT 2>/dev/null || iptables -I INPUT -p udp --dport $PORT -j ACCEPT 2>/dev/null
}

# 显示配置信息
show_info() {
    LINK="hy2://${PASS}@${IP}:${PORT}?sni=bing.com&insecure=1#Hysteria2"
    echo ""
    echo -e "${C}═══════════════════════════════════════${P}"
    echo -e "${G}   ✓ Hysteria 2 安装成功${P}"
    echo -e "${C}═══════════════════════════════════════${P}"
    echo -e "${Y}服务器${P}: $IP"
    echo -e "${Y}端口${P}  : $PORT"
    echo -e "${Y}密码${P}  : $PASS"
    echo -e "${C}───────────────────────────────────────${P}"
    echo -e "${Y}分享链接${P}:"
    echo -e "${G}${LINK}${P}"
    echo -e "${C}═══════════════════════════════════════${P}"
    echo -e "${Y}管理命令${P}:"
    echo -e "  状态: ${C}systemctl status hysteria-server${P}"
    echo -e "  重启: ${C}systemctl restart hysteria-server${P}"
    echo -e "  日志: ${C}journalctl -u hysteria-server -f${P}"
    echo -e "${C}═══════════════════════════════════════${P}"
    echo ""
    
    # 保存信息
    cat > /etc/hysteria/info.txt << EOF
服务器: $IP
端口: $PORT
密码: $PASS
链接: $LINK
EOF
}

# 安装主函数
install() {
    echo -e "${C}开始安装 Hysteria 2...${P}"
    detect_sys
    get_ip
    rand
    install_deps
    download_hy2
    gen_cert
    create_config
    create_service
    config_fw
    sleep 1
    show_info
}

# 卸载
uninstall() {
    echo -e "${Y}卸载 Hysteria 2...${P}"
    systemctl stop hysteria-server 2>/dev/null
    systemctl disable hysteria-server 2>/dev/null
    rm -rf /usr/local/bin/hysteria /etc/hysteria /etc/systemd/system/hysteria-server.service
    systemctl daemon-reload
    echo -e "${G}✓ 已卸载${P}"
}

# 查看配置
view_config() {
    if [[ ! -f /etc/hysteria/info.txt ]]; then
        echo -e "${R}未找到配置信息${P}"
        exit 1
    fi
    echo ""
    echo -e "${C}═══════════════════════════════════════${P}"
    cat /etc/hysteria/info.txt
    echo -e "${C}═══════════════════════════════════════${P}"
    echo ""
}

# 主菜单
menu() {
    clear
    echo -e "${C}╔═══════════════════════════════════════╗${P}"
    echo -e "${C}║${P}  ${G}Hysteria 2 极简安装脚本${P}          ${C}║${P}"
    echo -e "${C}╠═══════════════════════════════════════╣${P}"
    echo -e "${C}║${P}  ${G}1.${P} 安装                            ${C}║${P}"
    echo -e "${C}║${P}  ${G}2.${P} 查看配置                        ${C}║${P}"
    echo -e "${C}║${P}  ${G}3.${P} 重启服务                        ${C}║${P}"
    echo -e "${C}║${P}  ${G}4.${P} 查看日志                        ${C}║${P}"
    echo -e "${C}║${P}  ${R}5.${P} 卸载                            ${C}║${P}"
    echo -e "${C}║${P}  ${Y}0.${P} 退出                            ${C}║${P}"
    echo -e "${C}╚═══════════════════════════════════════╝${P}"
    echo ""
    read -rp "选择 [0-5]: " choice
    
    case $choice in
        1) install ;;
        2) view_config ;;
        3) systemctl restart hysteria-server && echo -e "${G}✓ 已重启${P}" ;;
        4) journalctl -u hysteria-server -f --no-pager -n 50 ;;
        5) uninstall ;;
        0) exit 0 ;;
        *) echo -e "${R}无效选项${P}"; sleep 1; menu ;;
    esac
    
    echo ""
    read -rp "按回车继续..."
    menu
}

# 主函数
main() {
    if [[ $# -eq 0 ]]; then
        menu
    else
        case $1 in
            install) install ;;
            uninstall) uninstall ;;
            config) view_config ;;
            restart) systemctl restart hysteria-server ;;
            status) systemctl status hysteria-server ;;
            logs) journalctl -u hysteria-server -f ;;
            *) echo "Usage: $0 {install|uninstall|config|restart|status|logs}"; exit 1 ;;
        esac
    fi
}

main "$@"
