#!/bin/bash
# Hysteria 2 企业级安装脚本 | Enterprise Hysteria 2 Installer
# 版本 | Version: 2.0.0
# 支持 | Support: Debian 11+ / Ubuntu 20.04+ / CentOS 7+
# GitHub: https://github.com/KyBronte/hysteria2

set -e
export LANG=en_US.UTF-8

# ==================== 全局配置 ====================
readonly SCRIPT_VERSION="2.0.0"
readonly HY2_DIR="/etc/hysteria"
readonly HY2_CONFIG="${HY2_DIR}/config.yaml"
readonly HY2_BINARY="/usr/local/bin/hysteria"
readonly HY2_SERVICE="/etc/systemd/system/hysteria-server.service"
readonly CERT_DIR="${HY2_DIR}/certs"
readonly CONFIG_BACKUP="${HY2_DIR}/configs"
readonly VERSION_FILE="${HY2_DIR}/version"
readonly CERT_MODE_FILE="${HY2_DIR}/cert_mode"

# GitHub 镜像源
GITHUB_PROXY=""
declare -A MIRRORS=(
    ["官方 GitHub"]="https://github.com"
    ["ghproxy 镜像"]="https://mirror.ghproxy.com/https://github.com"
    ["fastgit 镜像"]="https://download.fastgit.org"
)

# 颜色定义
readonly R='\033[0;31m'  # Red
readonly G='\033[0;32m'  # Green
readonly Y='\033[1;33m'  # Yellow
readonly C='\033[0;36m'  # Cyan
readonly B='\033[0;34m'  # Blue
readonly P='\033[0m'     # Plain

# ==================== 工具函数 ====================
echo_info()    { echo -e "${C}[INFO]${P} $*"; }
echo_success() { echo -e "${G}[SUCCESS]${P} $*"; }
echo_error()   { echo -e "${R}[ERROR]${P} $*"; }
echo_warning() { echo -e "${Y}[WARNING]${P} $*"; }
echo_step()    { echo -e "${B}[STEP]${P} $*"; }

error_exit() {
    echo_error "$1"
    exit "${2:-1}"
}

check_root() {
    [[ $EUID -ne 0 ]] && error_exit "需要 root 权限，请使用 sudo 或 root 用户运行"
}

check_command() {
    command -v "$1" &>/dev/null || error_exit "缺少命令: $1，请先安装"
}

# ==================== 系统检测 ====================
detect_sys() {
    echo_step "检测系统环境..."
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VER=$VERSION_ID
    else
        error_exit "无法识别操作系统"
    fi
    
    case $(uname -m) in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7*) ARCH="armv7" ;;
        *) error_exit "不支持的架构: $(uname -m)" ;;
    esac
    
    echo_success "系统: $OS $OS_VER | 架构: $ARCH"
}

# ==================== 网络功能 ====================
check_network() {
    echo_step "检测网络连接..."
    
    if curl -s --max-time 5 https://www.google.com -o /dev/null; then
        echo_success "网络连接正常"
        return 0
    elif curl -s --connect-timeout 5 https://www.baidu.com -o /dev/null; then
        echo_warning "国际网络受限，建议使用镜像源"
        return 0
    else
        error_exit "网络连接失败，请检查网络配置"
    fi
}

select_github_mirror() {
    echo_step "选择下载源..."
    echo ""
    
    local i=1
    local keys=()
    for key in "${!MIRRORS[@]}"; do
        keys+=("$key")
        echo "  $i) $key"
        ((i++))
    done
    
    echo ""
    read -rp "请选择 [1-${#MIRRORS[@]}] (默认:1): " choice
    choice=${choice:-1}
    
    if [[ $choice -ge 1 && $choice -le ${#MIRRORS[@]} ]]; then
        local selected_key="${keys[$((choice-1))]}"
        GITHUB_PROXY="${MIRRORS[$selected_key]}"
        echo_success "已选择: $selected_key"
    else
        GITHUB_PROXY="https://github.com"
        echo_warning "无效选择，使用官方源"
    fi
}

optimize_udp_params() {
    echo_step "优化 UDP 网络参数..."
    
    cat >> /etc/sysctl.conf << EOF

# Hysteria 2 UDP优化
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192
EOF

    sysctl -p >/dev/null 2>&1 || echo_warning "部分参数设置失败"
    echo_success "UDP 参数优化完成"
}

get_public_ip() {
    echo_step "获取公网 IP..."
    
    IP=$(curl -s4 --max-time 5 ip.sb 2>/dev/null || \
         curl -s4 --max-time 5 ifconfig.me 2>/dev/null || \
         curl -s4 --max-time 5 api.ipify.org 2>/dev/null)
    
    if [[ -z "$IP" ]]; then
        IP=$(curl -s6 --max-time 5 ip.sb 2>/dev/null || echo "")
    fi
    
    if [[ -z "$IP" ]]; then
        echo_warning "无法自动获取公网 IP"
        read -rp "请手动输入服务器公网 IP: " IP
    fi
    
    echo_success "服务器 IP: $IP"
}

# ==================== 依赖管理 ====================
install_deps() {
    echo_step "安装依赖包..."
    
    case $OS in
        debian|ubuntu)
            apt update -qq
            apt install -y -qq curl wget openssl jq net-tools >/dev/null 2>&1
            ;;
        centos|rhel|rocky|almalinux)
            yum install -y -q curl wget openssl jq net-tools >/dev/null 2>&1
            ;;
        *)
            echo_warning "未知系统，跳过依赖安装"
            ;;
    esac
}

verify_deps() {
    echo_step "验证依赖..."
    
    local deps=("curl" "wget" "openssl" "jq")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error_exit "缺少依赖: ${missing[*]}"
    fi
    
    echo_success "所有依赖已安装"
}

# ==================== 端口管理 ====================
check_port_occupied() {
    local port=$1
    
    if ss -tuln | grep -q ":${port} "; then
        return 0  # 被占用
    else
        return 1  # 空闲
    fi
}

validate_port() {
    local port=$1
    
    if [[ ! $port =~ ^[0-9]+$ ]] || [[ $port -lt 1 || $port -gt 65535 ]]; then
        return 1
    fi
    
    return 0
}

generate_random_port() {
    local port
    while true; do
        port=$((RANDOM % 40000 + 10000))
        if ! check_port_occupied "$port"; then
            echo "$port"
            return 0
        fi
    done
}

# ==================== Hysteria 2 核心 ====================
get_latest_version() {
    local api_url="https://api.github.com/repos/apernet/hysteria/releases/latest"
    local version
    
    version=$(curl -s --max-time 10 "$api_url" | jq -r '.tag_name' 2>/dev/null)
    
    if [[ -z "$version" || "$version" == "null" ]]; then
        version="app/v2.6.1"
        echo_warning "无法获取最新版本，使用默认: $version"
    fi
    
    echo "$version"
}

download_hysteria() {
    echo_step "下载 Hysteria 2..."
    
    local version
    version=$(get_latest_version)
    
    local download_url="${GITHUB_PROXY}/apernet/hysteria/releases/download/${version}/hysteria-linux-${ARCH}"
    local temp_file="/tmp/hysteria_$$"
    
    echo_info "版本: $version"
    echo_info "下载地址: $download_url"
    
    if curl -L --progress-bar --max-time 300 -o "$temp_file" "$download_url"; then
        chmod +x "$temp_file"
        mv -f "$temp_file" "$HY2_BINARY"
        echo "$version" > "$VERSION_FILE"
        echo_success "Hysteria 2 下载完成"
    else
        rm -f "$temp_file"
        error_exit "下载失败，请检查网络或更换镜像源"
    fi
}

get_installed_version() {
    if [[ -f "$VERSION_FILE" ]]; then
        cat "$VERSION_FILE"
    else
        echo "未安装"
    fi
}

# ==================== 证书管理 ====================
check_port_80() {
    if check_port_occupied 80; then
        echo_warning "端口 80 已被占用，无法使用 ACME 模式"
        return 1
    fi
    return 0
}

generate_self_signed_cert() {
    echo_step "生成自签名证书..."
    
    mkdir -p "$CERT_DIR"
    
    openssl ecparam -genkey -name prime256v1 -out "${CERT_DIR}/server.key" 2>/dev/null
    openssl req -new -x509 -days 36500 -key "${CERT_DIR}/server.key" \
        -out "${CERT_DIR}/server.crt" -subj "/CN=bing.com" 2>/dev/null
    
    chmod 600 "${CERT_DIR}/server.key"
    chmod 644 "${CERT_DIR}/server.crt"
    
    echo "self-signed" > "$CERT_MODE_FILE"
    echo_success "自签名证书生成完成"
}

apply_acme_cert() {
    echo_step "申请 ACME 证书..."
    
    # 检查端口
    if ! check_port_80; then
        echo_error "端口 80 被占用，请释放后重试"
        return 1
    fi
    
    # 获取域名和邮箱
    read -rp "请输入域名: " domain
    read -rp "请输入邮箱: " email
    
    if [[ -z "$domain" || -z "$email" ]]; then
        echo_error "域名和邮箱不能为空"
        return 1
    fi
    
    # 安装 acme.sh
    if [[ ! -f ~/.acme.sh/acme.sh ]]; then
        curl -s https://get.acme.sh | sh -s email="$email" >/dev/null
    fi
    
    # 申请证书
    ~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
    if ~/.acme.sh/acme.sh --issue -d "$domain" --standalone --httpport 80 --force; then
        mkdir -p "$CERT_DIR"
        ~/.acme.sh/acme.sh --install-cert -d "$domain" \
            --key-file "${CERT_DIR}/server.key" \
            --fullchain-file "${CERT_DIR}/server.crt" \
            --reloadcmd "systemctl restart hysteria-server 2>/dev/null || true"
        
        chmod 600 "${CERT_DIR}/server.key"
        echo "acme:$domain" > "$CERT_MODE_FILE"
        echo_success "ACME 证书申请成功"
        return 0
    else
        echo_error "证书申请失败，请检查域名解析和防火墙"
        return 1
    fi
}

select_cert_mode() {
    echo ""
    echo "选择证书模式:"
    echo "  1) 自签名证书 (推荐，无需域名)"
    echo "  2) ACME 证书 (Let's Encrypt，需要域名)"
    echo ""
    
    read -rp "请选择 [1-2] (默认:1): " cert_choice
    cert_choice=${cert_choice:-1}
    
    case $cert_choice in
        1) generate_self_signed_cert ;;
        2) apply_acme_cert || generate_self_signed_cert ;;
        *) echo_warning "无效选择，使用自签名"; generate_self_signed_cert ;;
    esac
}

switch_cert_mode() {
    if [[ ! -f "$CERT_MODE_FILE" ]]; then
        echo_error "请先安装 Hysteria 2"
        return 1
    fi
    
    local current_mode
    current_mode=$(cat "$CERT_MODE_FILE")
    
    echo "当前证书模式: $current_mode"
    echo ""
    echo "切换到:"
    echo "  1) 自签名证书"
    echo "  2) ACME 证书"
    echo ""
    
    read -rp "请选择 [1-2]: " choice
    
    case $choice in
        1) generate_self_signed_cert && systemctl restart hysteria-server ;;
        2) apply_acme_cert && systemctl restart hysteria-server ;;
        *) echo_error "无效选择" ;;
    esac
}

# ==================== 配置管理 ====================
interactive_params() {
    echo_step "配置参数..."
    echo ""
    
    # 端口
    local default_port
    default_port=$(generate_random_port)
    while true; do
        read -rp "端口 [${default_port}]: " PORT
        PORT=${PORT:-$default_port}
        
        if validate_port "$PORT"; then
            if check_port_occupied "$PORT"; then
                echo_error "端口 $PORT 已被占用"
            else
                break
            fi
        else
            echo_error "端口必须在 1-65535 之间"
        fi
    done
    
    # 密码
    local default_pass
    default_pass=$(openssl rand -base64 18 | tr -d '/+=' | head -c 16)
    read -rp "密码 [${default_pass}]: " PASS
    PASS=${PASS:-$default_pass}
    
    # SNI
    read -rp "伪装域名 SNI [bing.com]: " SNI
    SNI=${SNI:-bing.com}
    
    # 混淆密码 (Salamander)
    read -rp "混淆密码 (可选，留空禁用): " OBFS_PASS
    
    # 带宽
    read -rp "上传带宽 (如 100mbps, 1gbps, 留空不限): " BW_UP
    read -rp "下载带宽 (如 100mbps, 1gbps, 留空不限): " BW_DOWN
    
    echo_success "参数配置完成"
}

create_config() {
    echo_step "创建配置文件..."
    
    mkdir -p "$HY2_DIR"
    
    cat > "$HY2_CONFIG" << EOF
# Hysteria 2 配置文件
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

listen: :${PORT}

tls:
  cert: ${CERT_DIR}/server.crt
  key: ${CERT_DIR}/server.key

auth:
  type: password
  password: "${PASS}"

masquerade:
  type: proxy
  proxy:
    url: https://${SNI}
    rewriteHost: true
EOF

    # 添加混淆
    if [[ -n "$OBFS_PASS" ]]; then
        cat >> "$HY2_CONFIG" << EOF

obfs:
  type: salamander
  salamander:
    password: "${OBFS_PASS}"
EOF
    fi
    
    # 添加带宽
    if [[ -n "$BW_UP" || -n "$BW_DOWN" ]]; then
        echo "" >> "$HY2_CONFIG"
        echo "bandwidth:" >> "$HY2_CONFIG"
        [[ -n "$BW_UP" ]] && echo "  up: ${BW_UP}" >> "$HY2_CONFIG"
        [[ -n "$BW_DOWN" ]] && echo "  down: ${BW_DOWN}" >> "$HY2_CONFIG"
    fi
    
    chmod 600 "$HY2_CONFIG"
    echo_success "配置文件已创建"
}

modify_config() {
    echo_step "修改配置..."
    
    if [[ ! -f "$HY2_CONFIG" ]]; then
        echo_error "配置文件不存在"
        return 1
    fi
    
    # 读取当前配置
    local current_port current_pass current_sni
    current_port=$(grep -oP 'listen: :\K\d+' "$HY2_CONFIG")
    current_pass=$(grep -oP 'password: "\K[^"]+' "$HY2_CONFIG")
    current_sni=$(grep -oP 'url: https://\K[^/]+' "$HY2_CONFIG")
    
    echo "当前配置:"
    echo "  端口: $current_port"
    echo "  密码: $current_pass"
    echo "  SNI: $current_sni"
    echo ""
    
    # 修改端口
    read -rp "新端口 (留空保持): " new_port
    if [[ -n "$new_port" ]]; then
        if validate_port "$new_port" && ! check_port_occupied "$new_port"; then
            sed -i "s/listen: :${current_port}/listen: :${new_port}/" "$HY2_CONFIG"
            PORT=$new_port
            echo_success "端口已更新: $new_port"
        fi
    else
        PORT=$current_port
    fi
    
    # 修改密码
    read -rp "新密码 (留空保持): " new_pass
    if [[ -n "$new_pass" ]]; then
        sed -i "s/password: \"${current_pass}\"/password: \"${new_pass}\"/" "$HY2_CONFIG"
        PASS=$new_pass
        echo_success "密码已更新"
    else
        PASS=$current_pass
    fi
    
    # 修改SNI
    read -rp "新 SNI (留空保持): " new_sni
    if [[ -n "$new_sni" ]]; then
        sed -i "s|url: https://${current_sni}|url: https://${new_sni}|" "$HY2_CONFIG"
        SNI=$new_sni
        echo_success "SNI 已更新: $new_sni"
    else
        SNI=$current_sni
    fi
    
    systemctl restart hysteria-server
    generate_all_configs
    echo_success "配置修改完成，服务已重启"
}

# ==================== 服务管理 ====================
create_service() {
    echo_step "创建系统服务..."
    
    cat > "$HY2_SERVICE" << 'EOF'
[Unit]
Description=Hysteria 2 Server
Documentation=https://hysteria.network/
After=network.target network-online.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/hysteria server -c /etc/hysteria/config.yaml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable hysteria-server --now >/dev/null 2>&1
    
    sleep 2
    if systemctl is-active --quiet hysteria-server; then
        echo_success "服务启动成功"
    else
        echo_warning "服务启动可能异常，请检查日志"
    fi
}

# ==================== 防火墙配置 ====================
config_firewall() {
    echo_step "配置防火墙..."
    
    # UFW
    if command -v ufw &>/dev/null && ufw status | grep -q "active"; then
        ufw allow "${PORT}/udp" >/dev/null 2>&1
        echo_info "UFW: 已放行 ${PORT}/udp"
    fi
    
    # firewalld
    if command -v firewall-cmd &>/dev/null && systemctl is-active --quiet firewalld; then
        firewall-cmd --permanent --add-port="${PORT}/udp" >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
        echo_info "firewalld: 已放行 ${PORT}/udp"
    fi
    
    # iptables
    if command -v iptables &>/dev/null; then
        iptables -C INPUT -p udp --dport "$PORT" -j ACCEPT 2>/dev/null || \
            iptables -I INPUT -p udp --dport "$PORT" -j ACCEPT
        echo_info "iptables: 已放行 ${PORT}/udp"
    fi
    
    echo_success "防火墙配置完成"
}

# ==================== 客户端配置生成 ====================
generate_hy2_link() {
    local insecure="1"
    [[ -f "$CERT_MODE_FILE" ]] && [[ $(cat "$CERT_MODE_FILE") == acme:* ]] && insecure="0"
    
    local link="hy2://${PASS}@${IP}:${PORT}?sni=${SNI}&insecure=${insecure}"
    [[ -n "$OBFS_PASS" ]] && link="${link}&obfs=salamander&obfs-password=${OBFS_PASS}"
    link="${link}#Hysteria2"
    
    echo "$link"
}

generate_clash_meta() {
    mkdir -p "$CONFIG_BACKUP"
    
    local insecure="true"
    [[ -f "$CERT_MODE_FILE" ]] && [[ $(cat "$CERT_MODE_FILE") == acme:* ]] && insecure="false"
    
    cat > "${CONFIG_BACKUP}/clash-meta.yaml" << EOF
proxies:
  - name: Hysteria2
    type: hysteria2
    server: ${IP}
    port: ${PORT}
    password: ${PASS}
    sni: ${SNI}
    skip-cert-verify: ${insecure}
EOF

    [[ -n "$OBFS_PASS" ]] && cat >> "${CONFIG_BACKUP}/clash-meta.yaml" << EOF
    obfs: salamander
    obfs-password: ${OBFS_PASS}
EOF

    echo_info "Clash Meta 配置已保存: ${CONFIG_BACKUP}/clash-meta.yaml"
}

generate_sing_box() {
    mkdir -p "$CONFIG_BACKUP"
    
    local insecure="true"
    [[ -f "$CERT_MODE_FILE" ]] && [[ $(cat "$CERT_MODE_FILE") == acme:* ]] && insecure="false"
    
    cat > "${CONFIG_BACKUP}/sing-box.json" << EOF
{
  "type": "hysteria2",
  "tag": "hy2",
  "server": "${IP}",
  "server_port": ${PORT},
  "password": "${PASS}",
EOF

    if [[ -n "$OBFS_PASS" ]]; then
        cat >> "${CONFIG_BACKUP}/sing-box.json" << EOF
  "obfs": {
    "type": "salamander",
    "password": "${OBFS_PASS}"
  },
EOF
    fi
    
    cat >> "${CONFIG_BACKUP}/sing-box.json" << EOF
  "tls": {
    "enabled": true,
    "server_name": "${SNI}",
    "insecure": ${insecure}
  }
}
EOF

    echo_info "Sing-box 配置已保存: ${CONFIG_BACKUP}/sing-box.json"
}

generate_all_configs() {
    echo_step "生成客户端配置..."
    
    local link
    link=$(generate_hy2_link)
    
    mkdir -p "$CONFIG_BACKUP"
    
    cat > "${CONFIG_BACKUP}/info.txt" << EOF
═══════════════════════════════════════
        Hysteria 2 连接信息
═══════════════════════════════════════
服务器: ${IP}
端口: ${PORT}
密码: ${PASS}
SNI: ${SNI}
混淆: ${OBFS_PASS:-未启用}
═══════════════════════════════════════
分享链接:
${link}
═══════════════════════════════════════
EOF

    generate_clash_meta
    generate_sing_box
    
    echo_success "所有客户端配置已生成"
}

# ==================== 安装流程 ====================
install() {
    clear
    echo -e "${C}╔═══════════════════════════════════════╗${P}"
    echo -e "${C}║${P}  ${G}Hysteria 2 企业级安装向导${P}         ${C}║${P}"
    echo -e "${C}╚═══════════════════════════════════════╝${P}"
    echo ""
    
    check_root
    detect_sys
    check_network
    select_github_mirror
    
    get_public_ip
    interactive_params
    
    install_deps
    verify_deps
    download_hysteria
    optimize_udp_params
    
    select_cert_mode
    
    create_config
    create_service
    config_firewall
    
    generate_all_configs
    
    echo ""
    echo -e "${C}═══════════════════════════════════════${P}"
    echo -e "${G}   ✓ Hysteria 2 安装完成！${P}"
    echo -e "${C}═══════════════════════════════════════${P}"
    cat "${CONFIG_BACKUP}/info.txt"
    echo ""
    echo -e "${Y}管理命令:${P}"
    echo -e "  查看配置: ${C}bash $0 config${P}"
    echo -e "  修改配置: ${C}bash $0 modify${P}"
    echo -e "  查看日志: ${C}bash $0 logs${P}"
    echo -e "${C}═══════════════════════════════════════${P}"
}

# ==================== 更新功能 ====================
update_hysteria() {
    echo_step "更新 Hysteria 2 核心..."
    
    local current
    current=$(get_installed_version)
    echo_info "当前版本: $current"
    
    # 备份配置
    [[ -f "$HY2_CONFIG" ]] && cp "$HY2_CONFIG" "${HY2_CONFIG}.bak"
    
    # 下载新版本
    download_hysteria
    
    # 重启服务
    systemctl restart hysteria-server
    
    local new
    new=$(get_installed_version)
    echo_success "更新完成: $current -> $new"
}

# ==================== 卸载功能 ====================
uninstall() {
    echo_warning "确定要卸载 Hysteria 2? [y/N]"
    read -rp "> " confirm
    
    [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo_info "已取消"; return 0; }
    
    echo_step "卸载 Hysteria 2..."
    
    systemctl stop hysteria-server 2>/dev/null || true
    systemctl disable hysteria-server 2>/dev/null || true
    
    rm -rf "$HY2_BINARY" "$HY2_SERVICE" "$HY2_DIR"
    
    systemctl daemon-reload
    
    echo_success "Hysteria 2 已完全卸载"
}

# ==================== 菜单系统 ====================
show_menu() {
    clear
    
    local version
    version=$(get_installed_version)
    
    echo -e "${C}╔═══════════════════════════════════════╗${P}"
    echo -e "${C}║${P}  ${G}Hysteria 2 企业级管理脚本 v${SCRIPT_VERSION}${P}  ${C}║${P}"
    echo -e "${C}║${P}  ${Y}当前版本: ${version}${P}"
    echo -e "${C}╠═══════════════════════════════════════╣${P}"
    echo -e "${C}║${P}  ${G}1.${P} 安装 Hysteria 2                  ${C}║${P}"
    echo -e "${C}║${P}  ${G}2.${P} 切换证书模式                     ${C}║${P}"
    echo -e "${C}║${P}  ${G}3.${P} 修改配置                         ${C}║${P}"
    echo -e "${C}║${P}  ${G}4.${P} 更新核心                         ${C}║${P}"
    echo -e "${C}║${P}  ${G}5.${P} 查看配置                         ${C}║${P}"
    echo -e "${C}║${P}  ${G}6.${P} 查看日志                         ${C}║${P}"
    echo -e "${C}║${P}  ${R}7.${P} 卸载                             ${C}║${P}"
    echo -e "${C}║${P}  ${Y}0.${P} 退出                             ${C}║${P}"
    echo -e "${C}╚═══════════════════════════════════════╝${P}"
    echo ""
    read -rp "请选择 [0-7]: " choice
    
    case $choice in
        1) install ;;
        2) switch_cert_mode ;;
        3) modify_config ;;
        4) update_hysteria ;;
        5) [[ -f "${CONFIG_BACKUP}/info.txt" ]] && cat "${CONFIG_BACKUP}/info.txt" || echo_error "未找到配置信息" ;;
        6) journalctl -u hysteria-server -f --no-pager -n 100 ;;
        7) uninstall ;;
        0) exit 0 ;;
        *) echo_error "无效选项" ;;
    esac
    
    echo ""
    read -rp "按回车继续..."
    show_menu
}

# ==================== 主函数 ====================
main() {
    if [[ $# -eq 0 ]]; then
        show_menu
    else
        case $1 in
            install) install ;;
            update) update_hysteria ;;
            modify) modify_config ;;
            switch) switch_cert_mode ;;
            config) [[ -f "${CONFIG_BACKUP}/info.txt" ]] && cat "${CONFIG_BACKUP}/info.txt" || echo_error "未找到配置" ;;
            logs) journalctl -u hysteria-server -f ;;
            uninstall) uninstall ;;
            *) echo "Usage: $0 {install|update|modify|switch|config|logs|uninstall}"; exit 1 ;;
        esac
    fi
}

main "$@"
