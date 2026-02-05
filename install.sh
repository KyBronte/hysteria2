#!/bin/bash
# Hysteria 2 一键安装脚本 | Hysteria 2 One-Click Installer
# 版本 | Version: 2.1.0
# 支持 | Support: Debian 11+ / Ubuntu 20.04+ / CentOS 7+
# GitHub: https://github.com/KyBronte/hysteria2

# 不使用 set -e，避免 systemctl status 等返回非0时退出菜单
# set -e

# ==================== 全局变量 ====================
export LC_ALL=C
export LANG=C
export LANGUAGE=C

# 颜色定义
R='\033[0;31m'
G='\033[0;32m'
Y='\033[0;33m'
B='\033[0;34m'
C='\033[0;36m'
P='\033[0m'

# 语言模式 | Language Mode (zh=中文, en=English)
LANG_MODE="zh"

# 翻译函数 | Translation function
t() {
    local key="$1"
    if [[ "$LANG_MODE" == "zh" ]]; then
        case "$key" in
            # === 菜单 ===
            "menu.title") echo "Hysteria 2 管理脚本" ;;
            "menu.version") echo "版本" ;;
            "menu.status") echo "状态" ;;
            "menu.running") echo "运行中" ;;
            "menu.stopped") echo "已停止" ;;
            "menu.not_installed") echo "未安装" ;;
            "menu.install") echo "安装 Hysteria 2" ;;
            "menu.view_config") echo "查看配置" ;;
            "menu.modify_config") echo "修改配置" ;;
            "menu.service") echo "服务管理" ;;
            "menu.switch_cert") echo "切换证书模式" ;;
            "menu.update") echo "更新核心" ;;
            "menu.logs") echo "查看日志" ;;
            "menu.ports") echo "查看端口占用" ;;
            "menu.lang") echo "Change to English" ;;
            "menu.uninstall") echo "卸载 Hysteria 2" ;;
            "menu.exit") echo "退出" ;;
            "menu.select") echo "请选择" ;;
            "menu.invalid") echo "无效选项" ;;
            "menu.press_enter") echo "按回车键回到主菜单..." ;;
            # === 错误 ===
            "error.need_root") echo "需要 root 权限，请使用 sudo 或 root 用户运行" ;;
            "error.missing_cmd") echo "缺少命令" ;;
            "error.unknown_arg") echo "未知参数" ;;
            "error.cannot_identify_os") echo "无法识别操作系统" ;;
            "error.unsupported_arch") echo "不支持的架构" ;;
            "error.cannot_get_ip") echo "无法获取服务器 IP" ;;
            "error.missing_deps") echo "缺少关键依赖，安装终止" ;;
            "error.install_first") echo "请先安装 Hysteria 2" ;;
            # === 日志 ===
            "logs.viewing") echo "查看日志中... (按 Ctrl+C 返回菜单)" ;;
            "logs.exited") echo "已退出日志" ;;
            # === 安装流程 ===
            "install.title") echo "Hysteria 2 安装向导" ;;
            "install.detected") echo "检测到完整的 Hysteria 2 安装" ;;
            "install.overwrite") echo "是否覆盖现有配置?" ;;
            "install.cancelled") echo "已取消安装" ;;
            "install.overwriting") echo "将覆盖现有配置..." ;;
            "install.incomplete") echo "检测到不完整的配置，建议重新安装" ;;
            "install.select_mode") echo "请选择安装模式:" ;;
            "install.quick") echo "快速安装 (推荐) - 全部使用默认配置" ;;
            "install.custom") echo "自定义安装 - 手动配置各项参数" ;;
            "install.quick_selected") echo "已选择快速安装，将使用默认配置" ;;
            "install.custom_selected") echo "已选择自定义安装" ;;
            "install.starting") echo "开始安装..." ;;
            "install.success") echo "Hysteria 2 安装成功！" ;;
            "install.server") echo "服务器" ;;
            "install.port") echo "端口" ;;
            "install.password") echo "密码" ;;
            "install.sni") echo "SNI" ;;
            "install.obfs") echo "混淆" ;;
            "install.disabled") echo "未启用" ;;
            "install.share_link") echo "分享链接" ;;
            "install.qrcode") echo "二维码" ;;
            "install.config_saved") echo "配置文件已保存至" ;;
            "install.manage_cmd") echo "管理命令" ;;
            # === 系统检测 ===
            "detect.checking") echo "检测系统环境..." ;;
            "detect.os") echo "系统" ;;
            "detect.arch") echo "架构" ;;
            "detect.unsupported") echo "不支持的系统" ;;
            "detect.unknown") echo "未知" ;;
            "detect.not_installed") echo "未安装" ;;
            # === 网络检测 ===
            "network.checking") echo "检测网络连接..." ;;
            "network.ok") echo "网络连接正常" ;;
            "network.failed") echo "网络连接失败，请检查网络配置" ;;
            "network.github_ok") echo "GitHub API 可达" ;;
            "network.github_unavailable") echo "GitHub 直连不可用，建议使用镜像源" ;;
            "network.intl_limited") echo "国际网络受限，建议使用镜像源" ;;
            "network.getting_ip") echo "获取服务器 IP..." ;;
            "network.server_ip") echo "服务器 IP" ;;
            # === 下载源 ===
            "source.selecting") echo "选择下载源..." ;;
            "source.selected") echo "已选择" ;;
            "source.auto") echo "自动" ;;
            "source.custom") echo "自定义镜像 (参数指定)" ;;
            "source.github") echo "GitHub 下载源:" ;;
            "source.mirror") echo "国内系统软件源 (加速依赖下载):" ;;
            "source.invalid") echo "无效选择，默认使用官方源" ;;
            "source.system_configured") echo "系统软件源" ;;
            "source.hy_download") echo "Hysteria 下载源" ;;
            "source.official") echo "官方 GitHub (推荐)" ;;
            "source.ghproxy") echo "ghproxy 镜像" ;;
            "source.fastgit") echo "fastgit 镜像" ;;
            "source.tsinghua") echo "清华大学镜像源" ;;
            "source.aliyun") echo "阿里云镜像源" ;;
            "source.ustc") echo "中科大镜像源" ;;
            "source.configuring") echo "配置国内软件源" ;;
            "source.unsupported_os") echo "暂不支持该系统的软件源配置" ;;
            # === 配置参数 ===
            "params.configuring") echo "配置参数..." ;;
            "params.done") echo "参数配置完成" ;;
            "params.port") echo "端口" ;;
            "params.port_occupied") echo "端口已被占用" ;;
            "params.port_invalid") echo "端口必须在 1-65535 之间" ;;
            "params.port_mode") echo "端口使用模式:" ;;
            "params.single_port") echo "单端口 (默认)" ;;
            "params.port_hop") echo "端口跳跃 (增强抗封锁)" ;;
            "params.hop_start") echo "跳跃起始端口 (建议10000-60000)" ;;
            "params.hop_end") echo "跳跃结束端口 (必须大于起始端口)" ;;
            "params.hop_error") echo "起始端口必须小于结束端口，跳过端口跳跃配置" ;;
            "params.hop_enabled") echo "将启用端口跳跃" ;;
            "params.password") echo "密码" ;;
            "params.sni") echo "伪装域名 SNI" ;;
            "params.obfs") echo "混淆密码 (抗封锁/防探测, 留空禁用, 至少4字符)" ;;
            "params.obfs_short") echo "混淆密码过短，至少需要4个字符" ;;
            "params.bw_up") echo "上传带宽 (如100mbps, 1gbps, 留空不限)" ;;
            "params.bw_down") echo "下载带宽 (如100mbps, 1gbps, 留空不限)" ;;
            "params.info") echo "端口: %s | 密码: %s | SNI: %s" ;;
            "params.select") echo "请选择" ;;
            # === 依赖安装 ===
            "deps.installing") echo "安装依赖包" ;;
            "deps.verifying") echo "验证依赖..." ;;
            "deps.missing") echo "缺少必要依赖，无法继续" ;;
            "deps.partial_fail") echo "部分依赖安装失败，将继续检查" ;;
            "deps.unknown_os") echo "未知系统，跳过依赖安装" ;;
            "deps.check_passed") echo "依赖检查通过" ;;
            # === 下载核心 ===
            "download.core") echo "下载 Hysteria 核心" ;;
            "download.getting_version") echo "获取最新版本..." ;;
            "download.downloading") echo "下载 Hysteria 2..." ;;
            "download.version") echo "版本" ;;
            "download.url") echo "下载" ;;
            "download.failed") echo "下载失败" ;;
            "download.success") echo "Hysteria 2 下载完成" ;;
            # === 网络优化 ===
            "optimize.ask") echo "是否启用网络优化 (BBR+UDP)?" ;;
            "optimize.running") echo "优化网络参数 (UDP + BBR)..." ;;
            "optimize.skip") echo "跳过网络优化" ;;
            "optimize.bbr_ok") echo "BBR + FQ 已启用" ;;
            "optimize.bbr_fail") echo "BBR 启用验证失败" ;;
            "optimize.done") echo "网络参数优化完成" ;;
            "optimize.partial_fail") echo "部分参数设置失败" ;;
            # === 证书模式 ===
            "cert.selecting") echo "选择证书模式:" ;;
            "cert.mode") echo "证书模式:" ;;
            "cert.selfsigned") echo "自签名证书 (快速，无需域名)" ;;
            "cert.custom") echo "自有证书 (手动指定路径)" ;;
            "cert.generating") echo "生成自签名证书..." ;;
            "cert.done") echo "自签名证书生成完成" ;;
            "cert.fast_mode") echo "使用自签名证书 (快速安装)" ;;
            "cert.auto_selfsigned") echo "自动模式: 使用自签名证书" ;;
            "cert.path") echo "证书路径 (.crt)" ;;
            "cert.key_path") echo "私钥路径 (.key)" ;;
            "cert.custom_done") echo "自有证书已配置" ;;
            "cert.not_found") echo "证书不存在，使用自签名" ;;
            "cert.select_default") echo "选择 [1-2] (默认:1)" ;;
            # === 服务 ===
            "service.creating") echo "创建系统服务..." ;;
            "service.started") echo "服务启动成功" ;;
            "service.failed") echo "服务启动失败，请检查配置" ;;
            "service.autostart_ask") echo "是否设置 Hysteria 2 开机自启动?" ;;
            "service.autostart_on") echo "已设置开机自启动" ;;
            "service.autostart_off") echo "未设置开机自启动" ;;
            "service.restarted") echo "服务已重启" ;;
            "service.restart_failed") echo "服务重启失败" ;;
            "service.title") echo "服务管理" ;;
            "service.start") echo "启动服务" ;;
            "service.stop") echo "停止服务" ;;
            "service.restart") echo "重启服务" ;;
            "service.status") echo "查看状态" ;;
            "service.stopped") echo "服务已停止" ;;
            "service.start_failed") echo "启动失败" ;;
            "service.stop_failed") echo "停止失败" ;;
            "service.restart_fail") echo "重启失败" ;;
            # === 防火墙 ===
            "firewall.configuring") echo "配置防火墙..." ;;
            "firewall.opened") echo "已放行" ;;
            "firewall.done") echo "防火墙配置完成" ;;
            # === 端口跳跃 ===
            "hop.configuring") echo "配置端口跳跃" ;;
            "hop.done") echo "端口跳跃已配置" ;;
            # === 配置文件 ===
            "config.creating") echo "创建配置文件..." ;;
            "config.done") echo "配置文件已创建" ;;
            "config.not_found") echo "未找到配置文件" ;;
            "config.incomplete") echo "配置不完整，建议重新安装或重新生成配置" ;;
            "config.incomplete_link") echo "配置不完整，无法生成分享链接" ;;
            "config.current") echo "当前配置信息:" ;;
            "config.not_set") echo "未设置" ;;
            "config.invalid") echo "未设置或无效" ;;
            "config.regen") echo "重新生成客户端配置" ;;
            "config.return") echo "返回主菜单" ;;
            "config.title") echo "Hysteria 2 连接信息" ;;
            "config.hop_range") echo "跳跃" ;;
            # === 客户端配置 ===
            "client.generating") echo "生成客户端配置..." ;;
            "client.done") echo "所有客户端配置已生成" ;;
            "client.clash_saved") echo "Clash Meta 配置已保存" ;;
            "client.singbox_saved") echo "Sing-box 配置已保存" ;;
            "client.hy_yaml_saved") echo "hy-client.yaml 已保存" ;;
            "client.hy_json_saved") echo "hy-client.json 已保存" ;;
            # === 修改配置 ===
            "modify.title") echo "修改选项:" ;;
            "modify.port") echo "修改端口" ;;
            "modify.password") echo "修改密码" ;;
            "modify.sni") echo "修改 SNI" ;;
            "modify.obfs") echo "修改混淆密码" ;;
            "modify.select") echo "选择 [1-4]" ;;
            "modify.new_port") echo "新端口" ;;
            "modify.new_password") echo "新密码" ;;
            "modify.new_sni") echo "新 SNI" ;;
            "modify.new_obfs") echo "新混淆密码 (留空删除)" ;;
            "modify.port_updated") echo "端口已修改为" ;;
            "modify.password_updated") echo "密码已修改" ;;
            "modify.sni_updated") echo "SNI 已修改为" ;;
            "modify.obfs_updated") echo "混淆密码已修改" ;;
            "modify.obfs_disabled") echo "混淆已禁用" ;;
            "modify.invalid_port") echo "无效端口" ;;
            "modify.invalid_choice") echo "无效选择" ;;
            # === 更新 ===
            "update.title") echo "更新 Hysteria 2 核心..." ;;
            "update.current") echo "当前版本" ;;
            "update.done") echo "更新完成" ;;
            # === 端口占用 ===
            "ports.checking") echo "查看端口占用情况..." ;;
            "ports.hy_ports") echo "Hysteria 相关端口" ;;
            "ports.hop_rules") echo "端口跳跃规则 (HY2_HOP)" ;;
            "ports.fw_rules") echo "防火墙放行规则" ;;
            "ports.no_port") echo "无 Hysteria 相关端口占用" ;;
            "ports.no_hop") echo "无端口跳跃规则" ;;
            "ports.no_fw") echo "未找到相关 iptables 规则" ;;
            # === 卸载 ===
            "uninstall.confirm") echo "确定要卸载 Hysteria 2?" ;;
            "uninstall.keep_config") echo "是否保留配置和证书?" ;;
            "uninstall.title") echo "卸载 Hysteria 2..." ;;
            "uninstall.cleaning_hop") echo "清理端口跳跃规则..." ;;
            "uninstall.kept") echo "已保留配置目录" ;;
            "uninstall.deleted") echo "已删除所有配置和证书" ;;
            "uninstall.done") echo "Hysteria 2 已卸载" ;;
            # === 通用 ===
            "common.cancelled") echo "已取消" ;;
            # === 帮助 ===
            "help.title") echo "Hysteria 2 安装脚本" ;;
            "help.usage") echo "用法" ;;
            "help.commands") echo "命令" ;;
            "help.options") echo "选项" ;;
            "help.examples") echo "示例" ;;
            "help.cmd_install") echo "安装 Hysteria 2" ;;
            "help.cmd_update") echo "更新核心程序" ;;
            "help.cmd_modify") echo "修改配置" ;;
            "help.cmd_switch") echo "切换证书模式" ;;
            "help.cmd_config") echo "查看配置" ;;
            "help.cmd_logs") echo "查看日志" ;;
            "help.cmd_uninstall") echo "卸载" ;;
            "help.opt_port") echo "指定端口" ;;
            "help.opt_password") echo "指定密码" ;;
            "help.opt_sni") echo "指定 SNI 域名" ;;
            "help.opt_obfs") echo "指定混淆密码" ;;
            "help.opt_bw_up") echo "指定上传带宽" ;;
            "help.opt_bw_down") echo "指定下载带宽" ;;
            "help.opt_headless") echo "无交互模式" ;;
            "help.opt_help") echo "显示帮助" ;;
            # === 通用 ===
            "yes_no.default_y") echo "[Y/n]" ;;
            "yes_no.default_n") echo "[y/N]" ;;
            "default") echo "默认" ;;
            "common.by") echo "by" ;;
            "common.warning_multi_def") echo "配置文件存在多个定义，使用第一个" ;;
            *) echo "$key" ;;
        esac
    else
        # English
        case "$key" in
            # === Menu ===
            "menu.title") echo "Hysteria 2 Manager" ;;
            "menu.version") echo "Version" ;;
            "menu.status") echo "Status" ;;
            "menu.running") echo "Running" ;;
            "menu.stopped") echo "Stopped" ;;
            "menu.not_installed") echo "Not Installed" ;;
            "menu.install") echo "Install Hysteria 2" ;;
            "menu.view_config") echo "View Config" ;;
            "menu.modify_config") echo "Modify Config" ;;
            "menu.service") echo "Service Management" ;;
            "menu.switch_cert") echo "Switch Cert Mode" ;;
            "menu.update") echo "Update Core" ;;
            "menu.logs") echo "View Logs" ;;
            "menu.ports") echo "View Port Usage" ;;
            "menu.lang") echo "切换至中文" ;;
            "menu.uninstall") echo "Uninstall Hysteria 2" ;;
            "menu.exit") echo "Exit" ;;
            "menu.select") echo "Select" ;;
            "menu.invalid") echo "Invalid option" ;;
            "menu.press_enter") echo "Press Enter to return to menu..." ;;
            # === Errors ===
            "error.need_root") echo "Root required, run with sudo or as root" ;;
            "error.missing_cmd") echo "Missing command" ;;
            "error.unknown_arg") echo "Unknown argument" ;;
            "error.cannot_identify_os") echo "Cannot identify OS" ;;
            "error.unsupported_arch") echo "Unsupported architecture" ;;
            "error.cannot_get_ip") echo "Cannot get server IP" ;;
            "error.missing_deps") echo "Missing dependencies, aborting" ;;
            "error.install_first") echo "Please install Hysteria 2 first" ;;
            # === Logs ===
            "logs.viewing") echo "Viewing logs... (Ctrl+C to return)" ;;
            "logs.exited") echo "Exited logs" ;;
            # === Install Flow ===
            "install.title") echo "Hysteria 2 Installation Wizard" ;;
            "install.detected") echo "Complete Hysteria 2 installation detected" ;;
            "install.overwrite") echo "Overwrite existing config?" ;;
            "install.cancelled") echo "Installation cancelled" ;;
            "install.overwriting") echo "Overwriting existing config..." ;;
            "install.incomplete") echo "Incomplete config detected, reinstall recommended" ;;
            "install.select_mode") echo "Select installation mode:" ;;
            "install.quick") echo "Quick Install (Recommended) - Use default settings" ;;
            "install.custom") echo "Custom Install - Configure manually" ;;
            "install.quick_selected") echo "Quick install selected, using defaults" ;;
            "install.custom_selected") echo "Custom install selected" ;;
            "install.starting") echo "Starting installation..." ;;
            "install.success") echo "Hysteria 2 installed successfully!" ;;
            "install.server") echo "Server" ;;
            "install.port") echo "Port" ;;
            "install.password") echo "Password" ;;
            "install.sni") echo "SNI" ;;
            "install.obfs") echo "Obfs" ;;
            "install.disabled") echo "Disabled" ;;
            "install.share_link") echo "Share Link" ;;
            "install.qrcode") echo "QR Code" ;;
            "install.config_saved") echo "Config saved to" ;;
            "install.manage_cmd") echo "Management command" ;;
            # === System Detection ===
            "detect.checking") echo "Detecting system..." ;;
            "detect.os") echo "OS" ;;
            "detect.arch") echo "Arch" ;;
            "detect.unsupported") echo "Unsupported system" ;;
            "detect.unknown") echo "Unknown" ;;
            "detect.not_installed") echo "Not Installed" ;;
            # === Network Detection ===
            "network.checking") echo "Checking network..." ;;
            "network.ok") echo "Network OK" ;;
            "network.failed") echo "Network check failed" ;;
            "network.github_ok") echo "GitHub API reachable" ;;
            "network.github_unavailable") echo "GitHub unavailable, use mirror" ;;
            "network.intl_limited") echo "International network limited, use mirror" ;;
            "network.getting_ip") echo "Getting server IP..." ;;
            "network.server_ip") echo "Server IP" ;;
            # === Download Source ===
            "source.selecting") echo "Select download source..." ;;
            "source.selected") echo "Selected" ;;
            "source.auto") echo "Auto" ;;
            "source.custom") echo "Custom mirror (from args)" ;;
            "source.github") echo "GitHub Sources:" ;;
            "source.mirror") echo "China System Mirrors (faster deps):" ;;
            "source.invalid") echo "Invalid choice, using official" ;;
            "source.system_configured") echo "System mirror" ;;
            "source.hy_download") echo "Hysteria source" ;;
            "source.official") echo "Official GitHub (Recommended)" ;;
            "source.ghproxy") echo "ghproxy mirror" ;;
            "source.fastgit") echo "fastgit mirror" ;;
            "source.tsinghua") echo "Tsinghua Mirror" ;;
            "source.aliyun") echo "Aliyun Mirror" ;;
            "source.ustc") echo "USTC Mirror" ;;
            "source.configuring") echo "Configuring system mirror" ;;
            "source.unsupported_os") echo "System mirror not supported for this OS" ;;
            # === Config Parameters ===
            "params.configuring") echo "Configuring parameters..." ;;
            "params.done") echo "Parameters configured" ;;
            "params.port") echo "Port" ;;
            "params.port_occupied") echo "Port already in use" ;;
            "params.port_invalid") echo "Port must be 1-65535" ;;
            "params.port_mode") echo "Port mode:" ;;
            "params.single_port") echo "Single port (default)" ;;
            "params.port_hop") echo "Port hopping (anti-blocking)" ;;
            "params.hop_start") echo "Hop start port (10000-60000)" ;;
            "params.hop_end") echo "Hop end port (> start)" ;;
            "params.hop_error") echo "Start must be < end, skipping port hop" ;;
            "params.hop_enabled") echo "Port hopping enabled" ;;
            "params.password") echo "Password" ;;
            "params.sni") echo "Masquerade SNI" ;;
            "params.obfs") echo "Obfs password (anti-detect, empty=disable, min 4 chars)" ;;
            "params.obfs_short") echo "Obfs password too short, need 4+ chars" ;;
            "params.bw_up") echo "Upload bandwidth (e.g. 100mbps, empty=unlimited)" ;;
            "params.bw_down") echo "Download bandwidth (e.g. 100mbps, empty=unlimited)" ;;
            "params.info") echo "Port: %s | Password: %s | SNI: %s" ;;
            "params.select") echo "Select" ;;
            # === Dependencies ===
            "deps.installing") echo "Installing dependencies" ;;
            "deps.verifying") echo "Verifying dependencies..." ;;
            "deps.missing") echo "Missing dependencies, cannot continue" ;;
            "deps.partial_fail") echo "Some dependencies failed, will continue" ;;
            "deps.unknown_os") echo "Unknown OS, skipping deps install" ;;
            "deps.check_passed") echo "Dependency check passed" ;;
            # === Download Core ===
            "download.core") echo "Download Hysteria Core" ;;
            "download.getting_version") echo "Getting latest version..." ;;
            "download.downloading") echo "Downloading Hysteria 2..." ;;
            "download.version") echo "Version" ;;
            "download.url") echo "Download" ;;
            "download.failed") echo "Download failed" ;;
            "download.success") echo "Hysteria 2 downloaded" ;;
            # === Network Optimization ===
            "optimize.ask") echo "Enable network optimization (BBR+UDP)?" ;;
            "optimize.running") echo "Optimizing network (UDP + BBR)..." ;;
            "optimize.skip") echo "Skipping optimization" ;;
            "optimize.bbr_ok") echo "BBR + FQ enabled" ;;
            "optimize.bbr_fail") echo "BBR verification failed" ;;
            "optimize.done") echo "Network optimization complete" ;;
            "optimize.partial_fail") echo "Some params failed" ;;
            # === Certificate ===
            "cert.selecting") echo "Select certificate mode:" ;;
            "cert.mode") echo "Certificate mode:" ;;
            "cert.selfsigned") echo "Self-signed (quick, no domain)" ;;
            "cert.custom") echo "Custom certificate (specify path)" ;;
            "cert.generating") echo "Generating self-signed cert..." ;;
            "cert.done") echo "Self-signed cert generated" ;;
            "cert.fast_mode") echo "Using self-signed cert (quick install)" ;;
            "cert.auto_selfsigned") echo "Auto mode: Using self-signed cert" ;;
            "cert.path") echo "Cert path (.crt)" ;;
            "cert.key_path") echo "Key path (.key)" ;;
            "cert.custom_done") echo "Custom cert configured" ;;
            "cert.not_found") echo "Cert not found, using self-signed" ;;
            "cert.select_default") echo "Select [1-2] (default:1)" ;;
            # === Service ===
            "service.creating") echo "Creating system service..." ;;
            "service.started") echo "Service started" ;;
            "service.failed") echo "Service failed, check config" ;;
            "service.autostart_ask") echo "Enable Hysteria 2 auto-start?" ;;
            "service.autostart_on") echo "Auto-start enabled" ;;
            "service.autostart_off") echo "Auto-start disabled" ;;
            "service.restarted") echo "Service restarted" ;;
            "service.restart_failed") echo "Service restart failed" ;;
            "service.title") echo "Service Management" ;;
            "service.start") echo "Start service" ;;
            "service.stop") echo "Stop service" ;;
            "service.restart") echo "Restart service" ;;
            "service.status") echo "View status" ;;
            "service.stopped") echo "Service stopped" ;;
            "service.start_failed") echo "Start failed" ;;
            "service.stop_failed") echo "Stop failed" ;;
            "service.restart_fail") echo "Restart failed" ;;
            # === Firewall ===
            "firewall.configuring") echo "Configuring firewall..." ;;
            "firewall.opened") echo "Allowed" ;;
            "firewall.done") echo "Firewall configured" ;;
            # === Port Hopping ===
            "hop.configuring") echo "Configuring port hopping" ;;
            "hop.done") echo "Port hopping configured" ;;
            # === Config File ===
            "config.creating") echo "Creating config file..." ;;
            "config.done") echo "Config file created" ;;
            "config.not_found") echo "Config file not found" ;;
            "config.incomplete") echo "Config incomplete, reinstall or regenerate" ;;
            "config.incomplete_link") echo "Config incomplete, cannot generate link" ;;
            "config.current") echo "Current config:" ;;
            "config.not_set") echo "Not set" ;;
            "config.invalid") echo "Not set or invalid" ;;
            "config.regen") echo "Regenerate client configs" ;;
            "config.return") echo "Return to menu" ;;
            "config.title") echo "Hysteria 2 Connection Info" ;;
            "config.hop_range") echo "Hop range" ;;
            # === Client Config ===
            "client.generating") echo "Generating client configs..." ;;
            "client.done") echo "All client configs generated" ;;
            "client.clash_saved") echo "Clash Meta config saved" ;;
            "client.singbox_saved") echo "Sing-box config saved" ;;
            "client.hy_yaml_saved") echo "hy-client.yaml saved" ;;
            "client.hy_json_saved") echo "hy-client.json saved" ;;
            # === Modify Config ===
            "modify.title") echo "Modify Options:" ;;
            "modify.port") echo "Modify Port" ;;
            "modify.password") echo "Modify Password" ;;
            "modify.sni") echo "Modify SNI" ;;
            "modify.obfs") echo "Modify Obfs Password" ;;
            "modify.select") echo "Select [1-4]" ;;
            "modify.new_port") echo "New port" ;;
            "modify.new_password") echo "New password" ;;
            "modify.new_sni") echo "New SNI" ;;
            "modify.new_obfs") echo "New obfs password (empty to remove)" ;;
            "modify.port_updated") echo "Port changed to" ;;
            "modify.password_updated") echo "Password updated" ;;
            "modify.sni_updated") echo "SNI changed to" ;;
            "modify.obfs_updated") echo "Obfs password updated" ;;
            "modify.obfs_disabled") echo "Obfs disabled" ;;
            "modify.invalid_port") echo "Invalid port" ;;
            "modify.invalid_choice") echo "Invalid choice" ;;
            # === Update ===
            "update.title") echo "Updating Hysteria 2 core..." ;;
            "update.current") echo "Current version" ;;
            "update.done") echo "Update complete" ;;
            # === Port Usage ===
            "ports.checking") echo "Checking port usage..." ;;
            "ports.hy_ports") echo "Hysteria Ports" ;;
            "ports.hop_rules") echo "Port Hop Rules (HY2_HOP)" ;;
            "ports.fw_rules") echo "Firewall Rules" ;;
            "ports.no_port") echo "No Hysteria port in use" ;;
            "ports.no_hop") echo "No port hop rules" ;;
            "ports.no_fw") echo "No related iptables rules" ;;
            # === Uninstall ===
            "uninstall.confirm") echo "Uninstall Hysteria 2?" ;;
            "uninstall.keep_config") echo "Keep config and certs?" ;;
            "uninstall.title") echo "Uninstalling Hysteria 2..." ;;
            "uninstall.cleaning_hop") echo "Cleaning port hop rules..." ;;
            "uninstall.kept") echo "Config directory kept" ;;
            "uninstall.deleted") echo "All config and certs deleted" ;;
            "uninstall.done") echo "Hysteria 2 uninstalled" ;;
            # === Common ===
            "common.cancelled") echo "Cancelled" ;;
            # === Help ===
            "help.title") echo "Hysteria 2 Installer" ;;
            "help.usage") echo "Usage" ;;
            "help.commands") echo "Commands" ;;
            "help.options") echo "Options" ;;
            "help.examples") echo "Examples" ;;
            "help.cmd_install") echo "Install Hysteria 2" ;;
            "help.cmd_update") echo "Update core" ;;
            "help.cmd_modify") echo "Modify config" ;;
            "help.cmd_switch") echo "Switch cert mode" ;;
            "help.cmd_config") echo "View config" ;;
            "help.cmd_logs") echo "View logs" ;;
            "help.cmd_uninstall") echo "Uninstall" ;;
            "help.opt_port") echo "Specify port" ;;
            "help.opt_password") echo "Specify password" ;;
            "help.opt_sni") echo "Specify SNI domain" ;;
            "help.opt_obfs") echo "Specify obfs password" ;;
            "help.opt_bw_up") echo "Specify upload bandwidth" ;;
            "help.opt_bw_down") echo "Specify download bandwidth" ;;
            "help.opt_headless") echo "Non-interactive mode" ;;
            "help.opt_help") echo "Show help" ;;
            # === Common ===
            "yes_no.default_y") echo "[Y/n]" ;;
            "yes_no.default_n") echo "[y/N]" ;;
            "default") echo "default" ;;
            "common.by") echo "by" ;;
            "common.warning_multi_def") echo "Multiple definitions in config, using first" ;;
            *) echo "$key" ;;
        esac
    fi
}

# 语言切换函数
toggle_language() {
    if [[ "$LANG_MODE" == "zh" ]]; then
        LANG_MODE="en"
    else
        LANG_MODE="zh"
    fi
}

# 路径定义
readonly HY2_DIR="/etc/hysteria"
readonly HY2_BINARY="/usr/local/bin/hysteria"
readonly HY2_CONFIG="${HY2_DIR}/config.yaml"
readonly CERT_DIR="${HY2_DIR}/certs"
readonly CONFIG_BACKUP="${HY2_DIR}/configs"
readonly VERSION_FILE="${HY2_DIR}/version"
readonly CERT_MODE_FILE="${HY2_DIR}/cert_mode"
readonly HY2_SERVICE="/etc/systemd/system/hysteria-server.service"
readonly SYSCTL_CONF="/etc/sysctl.d/99-hysteria.conf"

# 版本信息
readonly SCRIPT_VERSION="2.1.0"
readonly DEFAULT_FALLBACK_VER="app/v2.7.0"

# 镜像源 (普通数组，官方在第一位)
MIRROR_NAMES=("官方 GitHub (推荐)" "ghproxy 镜像" "fastgit 镜像")
MIRROR_URLS=("https://github.com" "https://mirror.ghproxy.com/https://github.com" "https://download.fastgit.org")

# 临时文件
TEMP_FILE="/tmp/hysteria_$$"
cleanup() { [[ -n "$TEMP_FILE" && -f "$TEMP_FILE" ]] && rm -f "$TEMP_FILE"; }
trap cleanup EXIT INT TERM

# ==================== 工具函数 ====================
# 基础输出
echo_info()    { echo -e "${C}[INFO]${P} $*"; }
echo_success() { echo -e "${G}[SUCCESS]${P} $*"; }
echo_error()   { echo -e "${R}[ERROR]${P} $*"; }
echo_warning() { echo -e "${Y}[WARNING]${P} $*"; }
echo_step()    { echo -e "${B}[STEP]${P} $*"; }

# 翻译版输出 (传入 key)
echo_info_t()    { echo -e "${C}[INFO]${P} $(t "$1")"; }
echo_success_t() { echo -e "${G}[SUCCESS]${P} $(t "$1")"; }
echo_error_t()   { echo -e "${R}[ERROR]${P} $(t "$1")"; }
echo_warning_t() { echo -e "${Y}[WARNING]${P} $(t "$1")"; }
echo_step_t()    { echo -e "${B}[STEP]${P} $(t "$1")"; }

# 翻译版提示输入
prompt() {
    local key="$1" default="$2" var_name="$3"
    local prompt_text="$(t "$key")"
    [[ -n "$default" ]] && prompt_text="${prompt_text} [${default}]"
    read -rp "${prompt_text}: " "$var_name" || true
}

# 简单翻译提示 (返回用户输入)
prompt_yn() {
    local key="$1" default="$2"
    local result
    read -rp "$(t "$key") $(t "yes_no.default_${default}"): " result || true
    echo "${result:-${default^}}"
}

error_exit() {
    echo_error "$1"
    exit "${2:-1}"
}

# 统一状态输出包装器
run_task() {
    local desc="$1"; shift
    echo -ne "${C}[TASK]${P} ${desc} ... "
    if "$@" >/dev/null 2>&1; then
        echo -e "${G}ok${P}"
        return 0
    else
        echo -e "${R}failed${P}"
        return 1
    fi
}

# 翻译版 run_task
run_task_t() {
    local key="$1"; shift
    run_task "$(t "$key")" "$@"
}

# 防火墙端口更新 (幂等: 删旧加新)
update_firewall_port() {
    local old_port="$1" new_port="$2"
    
    # iptables
    if command -v iptables &>/dev/null; then
        iptables -D INPUT -p udp --dport "$old_port" -j ACCEPT 2>/dev/null || true
        iptables -C INPUT -p udp --dport "$new_port" -j ACCEPT 2>/dev/null || \
            iptables -I INPUT -p udp --dport "$new_port" -j ACCEPT
    fi
    
    # firewalld
    if command -v firewall-cmd &>/dev/null && systemctl is-active --quiet firewalld 2>/dev/null; then
        firewall-cmd --permanent --remove-port="${old_port}/udp" 2>/dev/null || true
        firewall-cmd --permanent --add-port="${new_port}/udp" 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
    fi
    
    # ufw
    if command -v ufw &>/dev/null && ufw status | grep -q "active"; then
        ufw delete allow "${old_port}/udp" 2>/dev/null || true
        ufw allow "${new_port}/udp" 2>/dev/null || true
    fi
    
    # 持久化
    netfilter-persistent save >/dev/null 2>&1 || true
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        error_exit "$(t 'error.need_root')"
    fi
}

check_command() {
    command -v "$1" &>/dev/null || error_exit "$(t 'error.missing_cmd'): $1"
}

# ==================== 视觉宽度计算 (Python) ====================
get_visual_width() {
    local str="$1"
    echo -n "$str" | python3 -c '
import sys, re, unicodedata
s = sys.stdin.read()
ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
s = ansi_escape.sub("", s)
width = sum(2 if unicodedata.east_asian_width(c) in ("W", "F") else 1 for c in s)
print(width)
'
}

# 打印带边框的行，自动填充空格以对齐右边框
print_padded_line() {
    local content="$1"
    local total_width="${2:-45}"
    local width
    width=$(get_visual_width "$content")
    local padding=$((total_width - width))
    [[ $padding -lt 0 ]] && padding=0
    local spaces=""
    for ((i=0; i<padding; i++)); do spaces+=" "; done
    echo -e "${C}║${P} ${content}${spaces} ${C}║${P}"
}

# 绘制边框线
draw_border_line() {
    local width="$1"
    local type="$2"
    local left="╔" right="╗"
    case "$type" in
        top) left="╔"; right="╗" ;;
        mid) left="╠"; right="╣" ;;
        bottom) left="╚"; right="╝" ;;
    esac
    local line=""
    for ((i=0; i<width+2; i++)); do line+="═"; done
    echo -e "${C}${left}${line}${right}${P}"
}

# ==================== 状态检测 ====================
get_installed_version() {
    if [[ -f "$HY2_BINARY" ]]; then
        "$HY2_BINARY" version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || echo "$(t 'detect.unknown')"
    else
        echo "$(t 'detect.not_installed')"
    fi
}

get_service_status() {
    if systemctl is-active --quiet hysteria-server 2>/dev/null; then
        echo -e "${G}● $(t 'menu.running')${P}"
    else
        echo -e "${R}● $(t 'menu.stopped')${P}"
    fi
}

# ==================== 配置解析辅助函数 ====================
# 稳健读取配置值 (自动 head -1 去重，检测多条匹配)
parse_config_value() {
    local field="$1"
    local pattern="$2"
    local result count
    
    result=$(grep -E "$pattern" "$HY2_CONFIG" 2>/dev/null | head -1)
    count=$(grep -cE "$pattern" "$HY2_CONFIG" 2>/dev/null || echo "0")
    
    if [[ "$count" -gt 1 ]]; then
        echo_warning "$(t 'common.warning_multi_def'): ${field}" >&2
    fi
    
    echo "$result"
}

# 读取端口 (listen: :PORT)
get_config_port() {
    local line
    line=$(parse_config_value "listen" "^listen:")
    echo "$line" | sed 's/.*://' | tr -d ' ' | head -1
}

# 读取密码 (auth block 内的 password)
get_config_password() {
    # 使用 awk 在 auth block 内查找 password
    awk '/^auth:/{found=1} found && /password:/{gsub(/.*password:[[:space:]]*"?/,""); gsub(/"$/,""); print; exit}' "$HY2_CONFIG" 2>/dev/null | head -1
}

# 读取 SNI (masquerade.proxy.url 域名部分)
get_config_sni() {
    # 查找 masquerade block 内的 url，提取域名
    awk '/^masquerade:/{found=1} found && /url:/{gsub(/.*https:\/\//,""); gsub(/["\/ ].*/,""); print; exit}' "$HY2_CONFIG" 2>/dev/null | head -1
}

# 读取混淆密码 (obfs.salamander.password)
get_config_obfs() {
    awk '/^obfs:/{found=1} found && /password:/{gsub(/.*password:[[:space:]]*"?/,""); gsub(/"$/,""); print; exit}' "$HY2_CONFIG" 2>/dev/null | head -1
}

# 检查安装完整性
is_config_complete() {
    [[ ! -f "$HY2_CONFIG" ]] && return 1
    
    local port pass sni
    port=$(get_config_port)
    pass=$(get_config_password)
    sni=$(get_config_sni)
    
    # 端口必须是有效数字 1-65535
    [[ ! "$port" =~ ^[0-9]+$ ]] && return 1
    [[ $port -lt 1 || $port -gt 65535 ]] && return 1
    
    # password 和 sni 非空
    [[ -z "$pass" ]] && return 1
    [[ -z "$sni" ]] && return 1
    
    return 0
}

is_hy2_installed() {
    # 检查所有必要组件
    [[ ! -f "$HY2_BINARY" ]] && return 1
    [[ ! -f "$HY2_SERVICE" ]] && return 1
    [[ ! -f "$HY2_CONFIG" ]] && return 1
    is_config_complete || return 1
    return 0
}

# ==================== Ctrl+C 可取消机制 ====================
CANCELLED=0
OLD_TRAP=""

setup_cancel_trap() {
    OLD_TRAP=$(trap -p INT)
    CANCELLED=0
    trap 'CANCELLED=1' INT
}

restore_trap() {
    if [[ -n "$OLD_TRAP" ]]; then
        eval "$OLD_TRAP"
    else
        trap - INT
    fi
    OLD_TRAP=""
}

check_cancelled() {
    if [[ $CANCELLED -eq 1 ]]; then
        restore_trap
        return 0
    fi
    return 1
}

# ==================== 运行时变量重置 ====================
reset_runtime_vars() {
    # 重置安装参数 (不影响 HEADLESS_MODE，由命令行控制)
    PORT="" PASS="" SNI="" OBFS_PASS=""
    PORT_RANGE_START="" PORT_RANGE_END=""
    FAST_MODE=false
    GITHUB_PROXY=""
}

# 绘制简化边框线 (无竖线)
draw_line() {
    local char="$1"
    local width="${2:-47}"
    local line=""
    for ((i=0; i<width; i++)); do line+="$char"; done
    echo -e "${C}${line}${P}"
}

# ==================== 主菜单 (简化 UI) ====================
show_menu() {
    while true; do
        clear
        
        local version status status_text
        version=$(get_installed_version)
        status=$(get_service_status)
        
        # 状态文本翻译
        if [[ "$status" == *"运行中"* || "$status" == *"Running"* ]]; then
            status_text="${G}$(t 'menu.running')${P}"
        elif [[ "$status" == *"已停止"* || "$status" == *"Stopped"* ]]; then
            status_text="${R}$(t 'menu.stopped')${P}"
        else
            status_text="${Y}$(t 'menu.not_installed')${P}"
        fi
        
        draw_line "═" 47
        echo -e "  ${G}$(t 'menu.title')${P} v${SCRIPT_VERSION}"
        echo -e "  $(t 'menu.version'): ${Y}${version}${P}  $(t 'menu.status'): ${status_text}"
        draw_line "─" 47
        echo -e "  ${G}1. $(t 'menu.install')${P}"
        echo -e "  2. $(t 'menu.view_config')"
        echo -e "  3. $(t 'menu.modify_config')"
        echo -e "  4. $(t 'menu.service')"
        echo -e "  5. $(t 'menu.switch_cert')"
        echo -e "  6. $(t 'menu.update')"
        echo -e "  7. $(t 'menu.logs')"
        echo -e "  8. $(t 'menu.ports')"
        echo -e "  9. $(t 'menu.lang')"
        echo -e "  ${R}10. $(t 'menu.uninstall')${P}"
        draw_line "─" 47
        echo -e "  ${R}0. $(t 'menu.exit')${P}"
        draw_line "═" 47
        
        echo ""
        read -rp "$(t 'menu.select') [0-10]: " choice
        
        case $choice in
            1) install ;;
            2) show_config_info ;;
            3) modify_config ;;
            4) service_manage ;;
            5) switch_cert_mode ;;
            6) update_hysteria ;;
            7) view_logs ;;
            8) show_port_usage ;;
            9) toggle_language ;;
            10) uninstall ;;
            0) exit 0 ;;
            *) echo_error "$(t 'menu.invalid')" ;;
        esac
        
        echo ""
        read -rp "$(t 'menu.press_enter')"
    done
}

# 查看日志 (带 Ctrl+C 处理)
view_logs() {
    echo_info "$(t 'logs.viewing')"
    
    # 保存旧 trap
    local old_trap exited_msg
    old_trap=$(trap -p INT)
    exited_msg="$(t 'logs.exited')"
    
    # 设置临时 trap (Ctrl+C 返回菜单)
    trap 'echo ""; echo_info "'"$exited_msg"'"' INT
    
    journalctl -u hysteria-server -f --no-pager -n 100 || true
    
    # 恢复旧 trap
    if [[ -n "$old_trap" ]]; then
        eval "$old_trap"
    else
        trap - INT
    fi
}

# 显示配置信息 (无子菜单版，用于安装前展示)
display_config_brief() {
    if [[ ! -f "$HY2_CONFIG" ]]; then
        return 1
    fi
    
    local port pass sni obfs ip
    port=$(get_config_port)
    pass=$(get_config_password)
    sni=$(get_config_sni)
    obfs=$(get_config_obfs)
    ip=$(curl -s4m5 ip.sb 2>/dev/null || curl -s6m5 ip.sb 2>/dev/null || echo "unknown")
    
    # 检测配置完整性
    local config_complete=true
    if [[ -z "$port" || ! "$port" =~ ^[0-9]+$ || $port -lt 1 || $port -gt 65535 ]]; then
        config_complete=false
    fi
    [[ -z "$pass" ]] && config_complete=false
    [[ -z "$sni" ]] && config_complete=false
    
    echo ""
    draw_line "─" 51
    echo -e "${Y}$(t 'config.current')${P}"
    echo -e " $(t 'install.server'): ${G}${ip}${P}"
    
    # 端口：单次输出
    if [[ -n "$port" && "$port" =~ ^[0-9]+$ && $port -ge 1 && $port -le 65535 ]]; then
        echo -e " $(t 'install.port')  : ${G}${port}${P}"
    else
        echo -e " $(t 'install.port')  : ${R}$(t 'config.invalid')${P}"
    fi
    
    # 密码：单次输出
    if [[ -n "$pass" ]]; then
        echo -e " $(t 'install.password')  : ${G}${pass}${P}"
    else
        echo -e " $(t 'install.password')  : ${R}$(t 'config.not_set')${P}"
    fi
    
    # SNI：单次输出
    if [[ -n "$sni" ]]; then
        echo -e " $(t 'install.sni')   : ${G}${sni}${P}"
    else
        echo -e " $(t 'install.sni')   : ${R}$(t 'config.not_set')${P}"
    fi
    
    [[ -n "$obfs" ]] && echo -e " $(t 'install.obfs')  : ${G}${obfs}${P}"
    
    # 仅配置完整时显示链接和二维码
    if [[ "$config_complete" == true ]]; then
        local insecure_flag link
        insecure_flag=$(get_insecure_flag)
        link="hy2://${pass}@${ip}:${port}?sni=${sni}&insecure=${insecure_flag}&alpn=h3"
        [[ -n "$obfs" ]] && link="${link}&obfs=salamander&obfs-password=${obfs}"
        link="${link}#Hysteria2"
        
        draw_line "─" 51
        echo -e "${Y}$(t 'install.share_link'):${P}"
        echo -e "${G}${link}${P}"
        
        if command -v qrencode &>/dev/null; then
            echo -e "${Y}$(t 'install.qrcode'):${P}"
            qrencode -t ANSIUTF8 "${link}"
        fi
    fi
    draw_line "─" 51
}

# 显示配置信息 (带子菜单版)
show_config_info() {
    if [[ ! -f "$HY2_CONFIG" ]]; then
        echo_error_t "config.not_found"
        echo_warning_t "config.incomplete"
        return 1
    fi
    
    local port pass sni obfs ip
    port=$(get_config_port)
    pass=$(get_config_password)
    sni=$(get_config_sni)
    obfs=$(get_config_obfs)
    ip=$(curl -s4m5 ip.sb 2>/dev/null || curl -s6m5 ip.sb 2>/dev/null || echo "unknown")
    
    # 检测配置完整性
    local config_complete=true
    if [[ -z "$port" || ! "$port" =~ ^[0-9]+$ || $port -lt 1 || $port -gt 65535 ]]; then
        config_complete=false
    fi
    [[ -z "$pass" ]] && config_complete=false
    [[ -z "$sni" ]] && config_complete=false
    
    echo ""
    draw_line "═" 51
    echo -e "${G}           $(t 'config.title')${P}"
    draw_line "═" 51
    echo ""
    echo -e " $(t 'install.server'): ${G}${ip}${P}"
    
    # 端口：单次 if/else 输出
    if [[ -n "$port" && "$port" =~ ^[0-9]+$ && $port -ge 1 && $port -le 65535 ]]; then
        echo -e " $(t 'install.port')  : ${G}${port}${P}"
    else
        echo -e " $(t 'install.port')  : ${R}$(t 'config.invalid')${P}"
    fi
    
    # 密码：单次 if/else 输出
    if [[ -n "$pass" ]]; then
        echo -e " $(t 'install.password')  : ${G}${pass}${P}"
    else
        echo -e " $(t 'install.password')  : ${R}$(t 'config.invalid')${P}"
    fi
    
    # SNI：单次 if/else 输出
    if [[ -n "$sni" ]]; then
        echo -e " $(t 'install.sni')   : ${G}${sni}${P}"
    else
        echo -e " $(t 'install.sni')   : ${R}$(t 'config.invalid')${P}"
    fi
    
    [[ -n "$obfs" ]] && echo -e " $(t 'install.obfs')  : ${G}${obfs}${P}"
    draw_line "─" 51
    
    # 仅配置完整时显示链接和二维码
    if [[ "$config_complete" == true ]]; then
        local insecure_flag link
        insecure_flag=$(get_insecure_flag)
        link="hy2://${pass}@${ip}:${port}?sni=${sni}&insecure=${insecure_flag}&alpn=h3"
        [[ -n "$obfs" ]] && link="${link}&obfs=salamander&obfs-password=${obfs}"
        link="${link}#Hysteria2"
        
        echo -e "${Y}$(t 'install.share_link'):${P}"
        echo -e "${G}${link}${P}"
        draw_line "─" 51
        
        if command -v qrencode &>/dev/null; then
            echo -e "${Y}$(t 'install.qrcode'):${P}"
            qrencode -t ANSIUTF8 "${link}"
        fi
    else
        echo_warning_t "config.incomplete_link"
    fi
    
    # 子菜单选项
    echo ""
    draw_line "─" 51
    echo -e "  ${G}R${P}. $(t 'config.regen')"
    echo -e "  ${Y}B${P}. $(t 'config.return')"
    echo ""
    read -rp "$(t 'menu.select'): " sub_choice || true
    
    case $sub_choice in
        [Rr])
            regenerate_configs
            ;;
        *)
            return 0
            ;;
    esac
}

# ==================== 系统检测 ====================
detect_sys() {
    echo_step_t "detect.checking"
    
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS=$ID
        OS_VER=$VERSION_ID
    else
        error_exit "$(t 'error.cannot_identify_os')"
    fi
    
    case $(uname -m) in
        x86_64|amd64) ARCH="amd64" ;;
        aarch64|arm64) ARCH="arm64" ;;
        armv7*) ARCH="armv7" ;;
        *)
            error_exit "$(t 'error.unsupported_arch'): $(uname -m)"
            ;;
    esac
    
    echo_success "$(t 'detect.os'): $OS $OS_VER | $(t 'detect.arch'): $ARCH"
}

# ==================== 网络功能 ====================
check_network() {
    echo_step_t "network.checking"
    
    if curl -fsS --max-time 5 https://api.github.com/repos/apernet/hysteria -o /dev/null 2>/dev/null; then
        echo_success "$(t 'network.github_ok')"
        return 0
    fi
    
    if curl -fsS --max-time 5 https://mirror.ghproxy.com/https://github.com -o /dev/null 2>/dev/null; then
        echo_warning "$(t 'network.github_unavailable')"
        return 0
    fi
    
    if curl -fsS --max-time 5 https://www.baidu.com -o /dev/null 2>/dev/null; then
        echo_warning "$(t 'network.intl_limited')"
        return 0
    fi
    
    error_exit "$(t 'network.failed')"
}

# 应用国内系统软件源 (helper function)
apply_system_mirror() {
    local mirror_url="$1"
    local mirror_name="$2"
    
    echo_step "$(t 'source.configuring'): ${mirror_name}..."
    
    case $OS in
        debian)
            cat > /etc/apt/sources.list << EOF
deb ${mirror_url}/debian/ $(lsb_release -cs 2>/dev/null || echo "bookworm") main contrib non-free non-free-firmware
deb ${mirror_url}/debian/ $(lsb_release -cs 2>/dev/null || echo "bookworm")-updates main contrib non-free non-free-firmware
deb ${mirror_url}/debian-security $(lsb_release -cs 2>/dev/null || echo "bookworm")-security main contrib non-free non-free-firmware
EOF
            ;;
        ubuntu)
            cat > /etc/apt/sources.list << EOF
deb ${mirror_url}/ubuntu/ $(lsb_release -cs 2>/dev/null || echo "jammy") main restricted universe multiverse
deb ${mirror_url}/ubuntu/ $(lsb_release -cs 2>/dev/null || echo "jammy")-updates main restricted universe multiverse
deb ${mirror_url}/ubuntu/ $(lsb_release -cs 2>/dev/null || echo "jammy")-security main restricted universe multiverse
EOF
            ;;
        centos|rhel|rocky|almalinux)
            [[ -d /etc/yum.repos.d.bak ]] || cp -r /etc/yum.repos.d /etc/yum.repos.d.bak
            if [[ "$OS" == "centos" ]]; then
                sed -i "s|^mirrorlist=|#mirrorlist=|g" /etc/yum.repos.d/CentOS-*.repo 2>/dev/null || true
                sed -i "s|^#baseurl=http://mirror.centos.org|baseurl=${mirror_url}|g" /etc/yum.repos.d/CentOS-*.repo 2>/dev/null || true
            fi
            ;;
        *)
            echo_warning "$(t 'source.unsupported_os')"
            return 1
            ;;
    esac
    return 0
}

# 统一下载源选择 (GitHub + 系统软件源)
select_download_source() {
    echo_step_t "source.selecting"
    
    # 自动模式或提供参数时跳过交互
    if [[ -n "$ARG_MIRROR" ]]; then
        GITHUB_PROXY="$ARG_MIRROR"
        echo_success "$(t 'source.selected'): $(t 'source.custom')"
        return 0
    fi
    
    if [[ "$HEADLESS_MODE" == true ]]; then
        GITHUB_PROXY="${MIRROR_URLS[0]}"
        echo_success "$(t 'source.selected'): $(t 'source.official') ($(t 'source.auto'))"
        return 0
    fi
    
    echo ""
    echo -e "${Y}$(t 'source.github')${P}"
    echo "  1) $(t 'source.official')"
    echo "  2) $(t 'source.ghproxy')"
    echo "  3) $(t 'source.fastgit')"
    echo -e "${Y}$(t 'source.mirror')${P}"
    echo "  4) $(t 'source.tsinghua')"
    echo "  5) $(t 'source.aliyun')"
    echo "  6) $(t 'source.ustc')"
    echo ""
    read -rp "$(t 'params.select') [1-6] ($(t 'default'):1): " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            GITHUB_PROXY="${MIRROR_URLS[0]}"
            echo_success "$(t 'source.selected'): $(t 'source.official')"
            ;;
        2)
            GITHUB_PROXY="${MIRROR_URLS[1]}"
            echo_success "$(t 'source.selected'): $(t 'source.ghproxy')"
            ;;
        3)
            GITHUB_PROXY="${MIRROR_URLS[2]}"
            echo_success "$(t 'source.selected'): $(t 'source.fastgit')"
            ;;
        4)
            apply_system_mirror "https://mirrors.tuna.tsinghua.edu.cn" "$(t 'source.tsinghua')" && \
                echo_success "$(t 'source.system_configured'): $(t 'source.tsinghua')"
            GITHUB_PROXY="${MIRROR_URLS[0]}"
            echo_success "$(t 'source.hy_download'): $(t 'source.official')"
            ;;
        5)
            apply_system_mirror "https://mirrors.aliyun.com" "$(t 'source.aliyun')" && \
                echo_success "$(t 'source.system_configured'): $(t 'source.aliyun')"
            GITHUB_PROXY="${MIRROR_URLS[0]}"
            echo_success "$(t 'source.hy_download'): $(t 'source.official')"
            ;;
        6)
            apply_system_mirror "https://mirrors.ustc.edu.cn" "$(t 'source.ustc')" && \
                echo_success "$(t 'source.system_configured'): $(t 'source.ustc')"
            GITHUB_PROXY="${MIRROR_URLS[0]}"
            echo_success "$(t 'source.hy_download'): $(t 'source.official')"
            ;;
        *)
            GITHUB_PROXY="${MIRROR_URLS[0]}"
            echo_warning "$(t 'source.invalid')"
            ;;
    esac
}

optimize_udp_params() {
    echo_step_t "optimize.running"
    
    cat > "$SYSCTL_CONF" << EOF
# Hysteria 2 network optimization
# Generated at: $(date '+%Y-%m-%d %H:%M:%S')

# UDP buffer optimization
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216
net.ipv4.udp_rmem_min = 8192
net.ipv4.udp_wmem_min = 8192

# Enable BBR congestion control
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
EOF
    sysctl -p "$SYSCTL_CONF" >/dev/null 2>&1 || echo_warning "$(t 'optimize.partial_fail')"
    
    # Apply system-level config
    sysctl --system >/dev/null 2>&1 || true
    
    if sysctl net.ipv4.tcp_congestion_control 2>/dev/null | grep -q "bbr"; then
        echo_success "$(t 'optimize.bbr_ok')"
    else
        echo_warning "$(t 'optimize.bbr_fail')"
    fi
    
    echo_success "$(t 'optimize.done')"
}

get_public_ip() {
    echo_step_t "network.getting_ip"
    IP=$(curl -s4m5 ip.sb 2>/dev/null || curl -s6m5 ip.sb 2>/dev/null)
    [[ -z "$IP" ]] && IP=$(curl -s4m5 ifconfig.me 2>/dev/null)
    [[ -z "$IP" ]] && error_exit "$(t 'error.cannot_get_ip')"
    echo_success "$(t 'network.server_ip'): $IP"
}

# ==================== 依赖安装 ====================
install_deps() {
    echo_step_t "deps.installing"
    
    case $OS in
        debian|ubuntu)
            apt update -qq
            echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections 2>/dev/null || true
            echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections 2>/dev/null || true
            if ! apt install -y -qq curl wget openssl jq net-tools qrencode python3 iptables-persistent netfilter-persistent >/dev/null 2>&1; then
                echo_warning "$(t 'deps.partial_fail')"
            fi
            ;;
        centos|rhel|rocky|almalinux)
            if ! yum install -y -q curl wget openssl jq net-tools qrencode python3 iptables-services >/dev/null 2>&1; then
                echo_warning "$(t 'deps.partial_fail')"
            fi
            ;;
        *)
            echo_warning "$(t 'deps.unknown_os')"
            ;;
    esac
}

verify_deps() {
    local missing=()
    for cmd in curl wget openssl python3; do
        command -v "$cmd" &>/dev/null || missing+=("$cmd")
    done
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        error_exit "$(t 'error.missing_deps'): ${missing[*]}"
    fi
    echo_success "$(t 'deps.check_passed')"
}

# ==================== 下载 Hysteria ====================
get_latest_version() {
    local latest
    latest=$(curl -sL "https://api.github.com/repos/apernet/hysteria/releases/latest" 2>/dev/null | grep '"tag_name"' | head -1 | cut -d'"' -f4)
    echo "${latest:-$DEFAULT_FALLBACK_VER}"
}

download_hysteria() {
    echo_step_t "download.downloading"
    
    local version
    version=$(get_latest_version)
    version=${version#app/}
    
    local url="${GITHUB_PROXY}/apernet/hysteria/releases/download/app/${version}/hysteria-linux-${ARCH}"
    
    echo_info "$(t 'download.version'): $version"
    echo_info "$(t 'download.url'): $url"
    
    if ! curl -L --progress-bar "$url" -o "$HY2_BINARY"; then
        error_exit "$(t 'download.failed')"
    fi
    
    chmod +x "$HY2_BINARY"
    echo_success "$(t 'download.success')"
    
    echo "$version" > "$VERSION_FILE"
}

# ==================== 端口工具 ====================
validate_port() {
    local port=$1
    [[ "$port" =~ ^[0-9]+$ ]] && [[ $port -ge 1 && $port -le 65535 ]]
}

check_port_occupied() {
    local port=$1
    netstat -tuln 2>/dev/null | grep -q ":${port} " && return 0
    ss -tuln 2>/dev/null | grep -q ":${port} " && return 0
    return 1
}

generate_random_port() {
    local port
    while true; do
        port=$((RANDOM % 55535 + 10000))
        check_port_occupied "$port" || { echo "$port"; return; }
    done
}

# ==================== 配置管理 ====================
interactive_params_auto() {
    echo_step_t "params.configuring"
    
    # 初始化变量
    PORT=""
    PASS=""
    SNI=""
    OBFS_PASS=""
    BW_UP=""
    BW_DOWN=""
    PORT_RANGE_START=""
    PORT_RANGE_END=""
    
    # ========== 端口 ==========
    if [[ -n "$ARG_PORT" ]]; then
        PORT="$ARG_PORT"
    elif [[ "$FAST_MODE" == true || "$HEADLESS_MODE" == true ]]; then
        PORT=$(generate_random_port)
    else
        echo ""
        local default_port
        default_port=$(generate_random_port)
        while true; do
            read -rp "$(t 'params.port') [${default_port}]: " PORT || true
            check_cancelled && return 1
            PORT=${PORT:-$default_port}
            
            if validate_port "$PORT"; then
                if check_port_occupied "$PORT"; then
                    echo_error "$(t 'params.port_occupied'): $PORT"
                else
                    break
                fi
            else
                echo_error "$(t 'params.port_invalid')"
            fi
        done
    fi
    
    # ========== 端口跳跃模式 (快速安装跳过) ==========
    if [[ "$FAST_MODE" != true && "$HEADLESS_MODE" != true ]]; then
        echo ""
        echo "$(t 'params.port_mode')"
        echo "  1) $(t 'params.single_port')"
        echo "  2) $(t 'params.port_hop')"
        read -rp "$(t 'params.select') [1-2]: " port_mode || true
        check_cancelled && return 1
        if [[ "$port_mode" == "2" ]]; then
            read -rp "$(t 'params.hop_start'): " PORT_RANGE_START || true
            check_cancelled && return 1
            read -rp "$(t 'params.hop_end'): " PORT_RANGE_END || true
            check_cancelled && return 1
            if [[ -n "$PORT_RANGE_START" && -n "$PORT_RANGE_END" ]]; then
                if [[ $PORT_RANGE_START -ge $PORT_RANGE_END ]]; then
                    echo_error "$(t 'params.hop_error')"
                    PORT_RANGE_START=""
                    PORT_RANGE_END=""
                else
                    echo_success "$(t 'params.hop_enabled'): ${PORT_RANGE_START}-${PORT_RANGE_END} -> ${PORT}"
                fi
            fi
        fi
    fi
    
    # ========== 密码 ==========
    if [[ -n "$ARG_PASS" ]]; then
        PASS="$ARG_PASS"
    elif [[ "$FAST_MODE" == true || "$HEADLESS_MODE" == true ]]; then
        PASS=$(openssl rand -base64 18 | tr -d '/+=' | head -c 16)
    else
        local default_pass
        default_pass=$(openssl rand -base64 18 | tr -d '/+=' | head -c 16)
        read -rp "$(t 'params.password') [${default_pass}]: " PASS || true
        check_cancelled && return 1
        PASS=${PASS:-$default_pass}
    fi
    
    # ========== SNI ==========
    if [[ -n "$ARG_SNI" ]]; then
        SNI="$ARG_SNI"
    elif [[ "$FAST_MODE" == true || "$HEADLESS_MODE" == true ]]; then
        SNI="www.bing.com"
    else
        read -rp "$(t 'params.sni') [www.bing.com]: " SNI || true
        check_cancelled && return 1
        SNI=${SNI:-www.bing.com}
    fi
    
    # ========== 混淆密码 (快速安装跳过) ==========
    if [[ -n "$ARG_OBFS" ]]; then
        OBFS_PASS="$ARG_OBFS"
    elif [[ "$FAST_MODE" != true && "$HEADLESS_MODE" != true ]]; then
        while true; do
            read -rp "$(t 'params.obfs'): " OBFS_PASS || true
            check_cancelled && return 1
            if [[ -z "$OBFS_PASS" ]]; then
                break
            elif [[ ${#OBFS_PASS} -ge 4 ]]; then
                break
            else
                echo_error "$(t 'params.obfs_short')"
            fi
        done
    fi
    
    # ========== 带宽 (快速安装跳过) ==========
    if [[ -n "$ARG_BW_UP" ]]; then
        BW_UP="$ARG_BW_UP"
    elif [[ "$FAST_MODE" != true && "$HEADLESS_MODE" != true ]]; then
        read -rp "$(t 'params.bw_up'): " BW_UP || true
        check_cancelled && return 1
    fi
    
    if [[ -n "$ARG_BW_DOWN" ]]; then
        BW_DOWN="$ARG_BW_DOWN"
    elif [[ "$FAST_MODE" != true && "$HEADLESS_MODE" != true ]]; then
        read -rp "$(t 'params.bw_down'): " BW_DOWN || true
        check_cancelled && return 1
    fi
    
    echo_success "$(t 'params.done')"
    echo_info "$(t 'params.port'): $PORT | $(t 'params.password'): $PASS | $(t 'params.sni'): $SNI"
}

create_config() {
    echo_step_t "config.creating"
    
    mkdir -p "$HY2_DIR"
    
    cat > "$HY2_CONFIG" << EOF
# Hysteria 2 config
# Generated at: $(date '+%Y-%m-%d %H:%M:%S')

listen: :${PORT}

tls:
  cert: ${CERT_DIR}/server.crt
  key: ${CERT_DIR}/server.key

# QUIC buffer optimization
quic:
  initStreamReceiveWindow: 16777216
  maxStreamReceiveWindow: 16777216
  initConnReceiveWindow: 33554432
  maxConnReceiveWindow: 33554432

auth:
  type: password
  password: "${PASS}"

masquerade:
  type: proxy
  proxy:
    url: https://${SNI}
    rewriteHost: true
EOF

    if [[ -n "$OBFS_PASS" ]]; then
        cat >> "$HY2_CONFIG" << EOF

obfs:
  type: salamander
  salamander:
    password: "${OBFS_PASS}"
EOF
    fi
    
    if [[ -n "$BW_UP" || -n "$BW_DOWN" ]]; then
        echo "" >> "$HY2_CONFIG"
        echo "bandwidth:" >> "$HY2_CONFIG"
        [[ -n "$BW_UP" ]] && echo "  up: ${BW_UP}" >> "$HY2_CONFIG"
        [[ -n "$BW_DOWN" ]] && echo "  down: ${BW_DOWN}" >> "$HY2_CONFIG"
    fi
    
    chmod 600 "$HY2_CONFIG"
    echo_success "$(t 'config.done')"
}

# ==================== 证书管理 ====================
select_cert_mode() {
    echo_step_t "cert.mode"
    
    if [[ "$HEADLESS_MODE" == true ]]; then
        echo_info "$(t 'cert.auto_selfsigned')"
        generate_self_signed_cert
        echo "selfsigned" > "$CERT_MODE_FILE"
        return

    fi
    
    echo ""
    echo "$(t 'cert.selecting')"
    echo "  1) $(t 'cert.selfsigned')"
    echo "  2) $(t 'cert.custom')"
    echo ""
    read -rp "$(t 'cert.select_default'): " cert_choice
    cert_choice=${cert_choice:-1}
    
    case $cert_choice in
        1)
            generate_self_signed_cert
            echo "selfsigned" > "$CERT_MODE_FILE"
            ;;
        2)
            read -rp "$(t 'cert.path'): " cert_path
            read -rp "$(t 'cert.key_path'): " key_path
            if [[ -f "$cert_path" && -f "$key_path" ]]; then
                mkdir -p "$CERT_DIR"
                cp "$cert_path" "${CERT_DIR}/server.crt"
                cp "$key_path" "${CERT_DIR}/server.key"
                echo "custom" > "$CERT_MODE_FILE"
                echo_success "$(t 'cert.custom_done')"
            else
                echo_warning "$(t 'cert.not_found')"
                generate_self_signed_cert
                echo "selfsigned" > "$CERT_MODE_FILE"
            fi
            ;;
        *)
            generate_self_signed_cert
            echo "selfsigned" > "$CERT_MODE_FILE"
            ;;
    esac
}

generate_self_signed_cert() {
    echo_step_t "cert.generating"
    mkdir -p "$CERT_DIR"
    
    openssl ecparam -genkey -name prime256v1 -out "${CERT_DIR}/server.key" 2>/dev/null
    openssl req -new -x509 -days 3650 -key "${CERT_DIR}/server.key" \
        -out "${CERT_DIR}/server.crt" -subj "/CN=www.bing.com" 2>/dev/null
    
    chmod 600 "${CERT_DIR}/server.key"
    echo_success "$(t 'cert.done')"
}

switch_cert_mode() {
    if [[ ! -f "$HY2_CONFIG" ]]; then
        echo_error_t "error.install_first"
        return 1
    fi
    
    select_cert_mode
    
    systemctl restart hysteria-server 2>/dev/null && echo_success "$(t 'service.restarted')" || echo_error "$(t 'service.restart_failed')"
}

# ==================== 服务管理 ====================
create_service() {
    echo_step_t "service.creating"
    
    cat > "$HY2_SERVICE" << EOF
[Unit]
Description=Hysteria 2 Server
After=network.target

[Service]
Type=simple
ExecStart=${HY2_BINARY} server -c ${HY2_CONFIG}
Restart=on-failure
RestartSec=5s
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl start hysteria-server
    
    sleep 2
    if systemctl is-active --quiet hysteria-server; then
        echo_success "$(t 'service.started')"
    else
        echo_error "$(t 'service.failed')"
        journalctl -u hysteria-server -n 20 --no-pager
        return 1
    fi
}

# ==================== 防火墙配置 ====================
config_firewall() {
    echo_step_t "firewall.configuring"
    
    if command -v iptables &>/dev/null; then
        iptables -C INPUT -p udp --dport "$PORT" -j ACCEPT 2>/dev/null || \
        iptables -I INPUT -p udp --dport "$PORT" -j ACCEPT
        echo_info "iptables: $(t 'firewall.opened') ${PORT}/udp"
    fi
    
    if command -v firewall-cmd &>/dev/null; then
        firewall-cmd --permanent --add-port="${PORT}/udp" 2>/dev/null || true
        firewall-cmd --reload 2>/dev/null || true
    fi
    
    if command -v ufw &>/dev/null; then
        ufw allow "${PORT}/udp" 2>/dev/null || true
    fi
    
    echo_success "$(t 'firewall.done')"
}

# ==================== 端口跳跃 ====================
setup_port_hopping() {
    if [[ -z "$PORT_RANGE_START" || -z "$PORT_RANGE_END" ]]; then
        return 0
    fi
    
    echo_step "$(t 'hop.configuring') (${PORT_RANGE_START}-${PORT_RANGE_END} -> ${PORT})..."
    
    # Create dedicated chain (IPv4)
    iptables -t nat -N HY2_HOP 2>/dev/null || true
    iptables -t nat -F HY2_HOP
    iptables -t nat -C PREROUTING -j HY2_HOP 2>/dev/null || \
        iptables -t nat -I PREROUTING -j HY2_HOP
    iptables -t nat -A HY2_HOP -p udp --dport ${PORT_RANGE_START}:${PORT_RANGE_END} -j DNAT --to-destination :${PORT}
    
    # Create dedicated chain (IPv6)
    ip6tables -t nat -N HY2_HOP 2>/dev/null || true
    ip6tables -t nat -F HY2_HOP 2>/dev/null || true
    ip6tables -t nat -C PREROUTING -j HY2_HOP 2>/dev/null || \
        ip6tables -t nat -I PREROUTING -j HY2_HOP 2>/dev/null || true
    ip6tables -t nat -A HY2_HOP -p udp --dport ${PORT_RANGE_START}:${PORT_RANGE_END} -j DNAT --to-destination :${PORT} 2>/dev/null || true
    
    # Save rules
    netfilter-persistent save >/dev/null 2>&1 || true
    echo_success "$(t 'hop.done')"
}

# ==================== 客户端配置生成 ====================
get_insecure_flag() {
    local cert_mode="selfsigned"
    [[ -f "$CERT_MODE_FILE" ]] && cert_mode=$(cat "$CERT_MODE_FILE")
    [[ "$cert_mode" == "selfsigned" ]] && echo "1" || echo "0"
}

generate_hy2_link() {
    local insecure_flag
    insecure_flag=$(get_insecure_flag)
    
    local link="hy2://${PASS}@${IP}:${PORT}?sni=${SNI}&insecure=${insecure_flag}&alpn=h3"
    [[ -n "$OBFS_PASS" ]] && link="${link}&obfs=salamander&obfs-password=${OBFS_PASS}"
    echo "${link}#Hysteria2"
}

generate_clash_meta() {
    local insecure_flag
    insecure_flag=$(get_insecure_flag)
    local skip_verify="false"
    [[ "$insecure_flag" == "1" ]] && skip_verify="true"
    
    cat > "${CONFIG_BACKUP}/clash-meta.yaml" << EOF
proxies:
  - name: Hysteria2
    type: hysteria2
    server: ${IP}
    port: ${PORT}
    password: ${PASS}
    sni: ${SNI}
    skip-cert-verify: ${skip_verify}
EOF

    [[ -n "$OBFS_PASS" ]] && cat >> "${CONFIG_BACKUP}/clash-meta.yaml" << EOF
    obfs: salamander
    obfs-password: ${OBFS_PASS}
EOF

    echo_info "$(t 'client.clash_saved'): ${CONFIG_BACKUP}/clash-meta.yaml"
}

generate_sing_box() {
    local insecure_flag
    insecure_flag=$(get_insecure_flag)
    local insecure_bool="false"
    [[ "$insecure_flag" == "1" ]] && insecure_bool="true"
    
    local obfs_config=""
    if [[ -n "$OBFS_PASS" ]]; then
        obfs_config=',
    "obfs": {
      "type": "salamander",
      "password": "'"${OBFS_PASS}"'"
    }'
    fi
    
    cat > "${CONFIG_BACKUP}/sing-box.json" << EOF
{
  "type": "hysteria2",
  "tag": "hysteria2",
  "server": "${IP}",
  "server_port": ${PORT},
  "password": "${PASS}",
  "tls": {
    "enabled": true,
    "server_name": "${SNI}",
    "insecure": ${insecure_bool}
  }${obfs_config}
}
EOF

    echo_info "$(t 'client.singbox_saved'): ${CONFIG_BACKUP}/sing-box.json"
}

generate_hy_client_yaml() {
    local display_ip="$IP"
    [[ "$IP" == *":"* ]] && display_ip="[$IP]"
    
    local port_str="${PORT}"
    [[ -n "$PORT_RANGE_START" ]] && port_str="${PORT},${PORT_RANGE_START}-${PORT_RANGE_END}"
    
    local insecure_flag
    insecure_flag=$(get_insecure_flag)
    local insecure_bool="false"
    [[ "$insecure_flag" == "1" ]] && insecure_bool="true"
    
    cat > "${CONFIG_BACKUP}/hy-client.yaml" << EOF
# Hysteria 2 客户端配置 (YAML)
# 生成时间: $(date '+%Y-%m-%d %H:%M:%S')

server: ${display_ip}:${port_str}

auth: ${PASS}

tls:
  sni: ${SNI}
  insecure: ${insecure_bool}

quic:
  initStreamReceiveWindow: 16777216
  maxStreamReceiveWindow: 16777216
  initConnReceiveWindow: 33554432
  maxConnReceiveWindow: 33554432

fastOpen: true

socks5:
  listen: 127.0.0.1:1080

http:
  listen: 127.0.0.1:8080

transport:
  udp:
    hopInterval: 30s
EOF

    echo_info "$(t 'client.hy_yaml_saved'): ${CONFIG_BACKUP}/hy-client.yaml"
}

generate_hy_client_json() {
    local display_ip="$IP"
    [[ "$IP" == *":"* ]] && display_ip="[$IP]"
    
    local port_str="${PORT}"
    [[ -n "$PORT_RANGE_START" ]] && port_str="${PORT},${PORT_RANGE_START}-${PORT_RANGE_END}"
    
    local insecure_flag
    insecure_flag=$(get_insecure_flag)
    local insecure_bool="false"
    [[ "$insecure_flag" == "1" ]] && insecure_bool="true"
    
    cat > "${CONFIG_BACKUP}/hy-client.json" << EOF
{
  "server": "${display_ip}:${port_str}",
  "auth": "${PASS}",
  "tls": {
    "sni": "${SNI}",
    "insecure": ${insecure_bool}
  },
  "quic": {
    "initStreamReceiveWindow": 16777216,
    "maxStreamReceiveWindow": 16777216,
    "initConnReceiveWindow": 33554432,
    "maxConnReceiveWindow": 33554432
  },
  "fastOpen": true,
  "socks5": {
    "listen": "127.0.0.1:1080"
  },
  "http": {
    "listen": "127.0.0.1:8080"
  },
  "transport": {
    "udp": {
      "hopInterval": "30s"
    }
  }
}
EOF

    echo_info "$(t 'client.hy_json_saved'): ${CONFIG_BACKUP}/hy-client.json"
}

generate_all_configs() {
    echo_step_t "client.generating"
    
    local link
    link=$(generate_hy2_link)
    
    local display_ip="$IP"
    [[ "$IP" == *":"* ]] && display_ip="[$IP]"
    
    local port_info="${PORT}"
    [[ -n "$PORT_RANGE_START" ]] && port_info="${PORT} ($(t 'config.hop_range'): ${PORT_RANGE_START}-${PORT_RANGE_END})"
    
    mkdir -p "$CONFIG_BACKUP"
    
    cat > "${CONFIG_BACKUP}/info.txt" << EOF
═══════════════════════════════════════
        $(t 'config.title')
═══════════════════════════════════════
$(t 'install.server'): ${display_ip}
$(t 'install.port'): ${port_info}
$(t 'install.password'): ${PASS}
$(t 'install.sni'): ${SNI}
$(t 'install.obfs'): ${OBFS_PASS:-$(t 'install.disabled')}
═══════════════════════════════════════
$(t 'install.share_link'):
${link}
═══════════════════════════════════════
EOF

    generate_clash_meta
    generate_sing_box
    generate_hy_client_yaml
    generate_hy_client_json
    
    echo_success "$(t 'client.done')"
}

# ==================== 安装流程 ====================
install() {
    # 重置运行时变量，避免上次残留
    reset_runtime_vars
    setup_cancel_trap
    
    clear
    draw_line "═" 51
    echo -e "  ${G}$(t 'install.title')${P} $(t 'common.by') GitHub@kybronte"
    draw_line "═" 51
    echo ""
    
    check_root
    check_cancelled && return 0
    
    run_task "$(t 'detect.checking')" detect_sys || detect_sys
    check_cancelled && return 0
    
    check_network
    check_cancelled && return 0
    
    # ========== 使用 is_hy2_installed 检测 ==========
    if is_hy2_installed; then
        echo ""
        echo -e "${Y}$(t 'install.detected')${P}"
        # 在询问覆盖前先展示当前配置
        display_config_brief
        echo ""
        read -rp "$(t 'install.overwrite') $(t 'yes_no.default_n'): " overwrite || true
        check_cancelled && return 0
        overwrite=${overwrite:-N}
        if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
            echo_info "$(t 'install.cancelled')"
            restore_trap
            return 0
        fi
        echo_info "$(t 'install.overwriting')"
        systemctl stop hysteria-server 2>/dev/null || true
    elif [[ -f "$HY2_CONFIG" ]] && ! is_config_complete; then
        echo_warning "$(t 'install.incomplete')"  
        systemctl stop hysteria-server 2>/dev/null || true
    fi
    check_cancelled && return 0
    
    # ========== 选择下载源 (非 HEADLESS 总是交互) ==========
    select_download_source
    check_cancelled && return 0
    
    get_public_ip
    check_cancelled && return 0
    
    # ========== 安装模式选择 ==========
    echo ""
    echo -e "${Y}$(t 'install.select_mode')${P}"
    echo "  1) $(t 'install.quick')"
    echo "  2) $(t 'install.custom')"
    echo ""
    read -rp "$(t 'params.select') [1-2] ($(t 'default'):1): " install_mode || true
    check_cancelled && return 0
    install_mode=${install_mode:-1}
    
    if [[ "$install_mode" == "1" ]]; then
        FAST_MODE=true
        echo_success "$(t 'install.quick_selected')"
    else
        FAST_MODE=false
        echo_info "$(t 'install.custom_selected')"
    fi
    check_cancelled && return 0
    
    interactive_params_auto
    check_cancelled && return 0
    
    echo ""
    echo_step_t "install.starting"
    run_task "$(t 'deps.installing')" install_deps || install_deps
    check_cancelled && return 0
    
    verify_deps
    check_cancelled && return 0
    
    run_task "$(t 'download.core')" download_hysteria || download_hysteria
    check_cancelled && return 0
    
    # ========== 可选的网络优化 ==========
    if [[ "$FAST_MODE" == true ]]; then
        # 快速安装：默认启用优化
        optimize_udp_params
    else
        echo ""
        read -rp "$(t 'optimize.ask') $(t 'yes_no.default_y'): " enable_optimize || true
        check_cancelled && return 0
        enable_optimize=${enable_optimize:-Y}
        if [[ "$enable_optimize" =~ ^[Yy]$ ]]; then
            optimize_udp_params
        else
            echo_info "$(t 'optimize.skip')"
        fi
    fi
    check_cancelled && return 0
    
    # ========== 证书模式 ==========
    if [[ "$FAST_MODE" == true ]]; then
        # 快速安装：默认自签名证书
        CERT_MODE="selfsigned"
        echo "$CERT_MODE" > "$CERT_MODE_FILE"
        echo_success "$(t 'cert.fast_mode')"
    else
        select_cert_mode
    fi
    check_cancelled && return 0
    
    create_config
    check_cancelled && return 0
    
    create_service
    check_cancelled && return 0
    
    config_firewall
    setup_port_hopping
    check_cancelled && return 0
    
    # ========== 是否开机自启动 ==========
    if [[ "$FAST_MODE" == true ]]; then
        # 快速安装：默认启用自启动
        systemctl enable hysteria-server 2>/dev/null || true
    else
        echo ""
        read -rp "$(t 'service.autostart_ask') $(t 'yes_no.default_y'): " enable_autostart || true
        check_cancelled && return 0
        enable_autostart=${enable_autostart:-Y}
        if [[ "$enable_autostart" =~ ^[Yy]$ ]]; then
            systemctl enable hysteria-server 2>/dev/null || true
            echo_success "$(t 'service.autostart_on')"
        else
            systemctl disable hysteria-server 2>/dev/null || true
            echo_info "$(t 'service.autostart_off')"
        fi
    fi
    
    generate_all_configs
    
    # 恢复 trap
    restore_trap
    
    # ========== 成功输出 (绿色高亮) ==========
    echo ""
    echo -e "${C}═══════════════════════════════════════════════════${P}"
    echo -e "${G}  ✔ $(t 'install.success')${P}"
    echo -e "${C}═══════════════════════════════════════════════════${P}"
    echo ""
    echo -e " $(t 'install.server'): ${G}${IP}${P}"
    echo -e " $(t 'install.port')  : ${G}${PORT}${P}"
    echo -e " $(t 'install.password')  : ${G}${PASS}${P}"
    echo -e " $(t 'install.sni')   : ${G}${SNI}${P}"
    echo -e " $(t 'install.obfs')  : ${G}${OBFS_PASS:-$(t 'install.disabled')}${P}"
    echo -e "${C}───────────────────────────────────────────────────${P}"
    echo -e "${Y}$(t 'install.share_link'):${P}"
    local display_link
    display_link=$(generate_hy2_link)
    echo -e "${G}${display_link}${P}"
    echo -e "${C}───────────────────────────────────────────────────${P}"
    
    if command -v qrencode &>/dev/null; then
        echo -e "${Y}$(t 'install.qrcode'):${P}"
        qrencode -t ANSIUTF8 "${display_link}"
    fi
    
    echo ""
    echo -e "${Y}$(t 'install.config_saved'): ${G}${CONFIG_BACKUP}/${P}"
    echo -e "$(t 'install.manage_cmd'): ${G}bash $0${P}"
}

# ==================== 更新功能 ====================
update_hysteria() {
    echo_step_t "update.title"
    
    local current
    current=$(get_installed_version)
    echo_info "$(t 'update.current'): $current"
    
    [[ -f "$HY2_CONFIG" ]] && cp "$HY2_CONFIG" "${HY2_CONFIG}.bak"
    
    detect_sys
    check_network
    select_download_source
    download_hysteria
    
    systemctl restart hysteria-server
    
    local new_ver
    new_ver=$(get_installed_version)
    echo_success "$(t 'update.done'): $current -> $new_ver"
}

# ==================== 修改配置 ====================
modify_config() {
    if [[ ! -f "$HY2_CONFIG" ]]; then
        echo_error_t "error.install_first"
        return 1
    fi
    
    echo ""
    echo "$(t 'modify.title')"
    echo "  1) $(t 'modify.port')"
    echo "  2) $(t 'modify.password')"
    echo "  3) $(t 'modify.sni')"
    echo "  4) $(t 'modify.obfs')"
    echo ""
    read -rp "$(t 'modify.select'): " modify_choice
    
    case $modify_choice in
        1)
            # 使用稳健的配置解析函数读取旧端口
            local old_port
            old_port=$(get_config_port)
            
            read -rp "$(t 'modify.new_port'): " new_port
            if validate_port "$new_port"; then
                sed -i "s/^listen: :.*/listen: :${new_port}/" "$HY2_CONFIG"
                
                # 使用统一的防火墙更新函数
                update_firewall_port "$old_port" "$new_port"
                
                PORT="$new_port"
                echo_success "$(t 'modify.port_updated'): $new_port"
            else
                echo_error "$(t 'modify.invalid_port')"
            fi
            ;;
        2)
            read -rp "$(t 'modify.new_password'): " new_pass
            sed -i "s/password: \".*\"/password: \"${new_pass}\"/" "$HY2_CONFIG"
            PASS="$new_pass"
            echo_success "$(t 'modify.password_updated')"
            ;;
        3)
            read -rp "$(t 'modify.new_sni'): " new_sni
            sed -i "s|url: https://.*|url: https://${new_sni}|" "$HY2_CONFIG"
            SNI="$new_sni"
            echo_success "$(t 'modify.sni_updated'): $new_sni"
            ;;
        4)
            read -rp "$(t 'modify.new_obfs'): " new_obfs
            if [[ -z "$new_obfs" ]]; then
                sed -i '/^obfs:/,/password:/d' "$HY2_CONFIG"
                OBFS_PASS=""
                echo_success "$(t 'modify.obfs_disabled')"
            else
                if grep -q "^obfs:" "$HY2_CONFIG"; then
                    sed -i "s/password: \".*\"/password: \"${new_obfs}\"/" "$HY2_CONFIG"
                else
                    cat >> "$HY2_CONFIG" << EOF

obfs:
  type: salamander
  salamander:
    password: "${new_obfs}"
EOF
                fi
                OBFS_PASS="$new_obfs"
                echo_success "$(t 'modify.obfs_updated')"
            fi
            ;;
        *)
            echo_error "$(t 'modify.invalid_choice')"
            return 1
            ;;
    esac
    
    systemctl restart hysteria-server && echo_success "$(t 'service.restarted')" || echo_error "$(t 'service.restart_failed')"
    
    get_public_ip
    PORT=$(get_config_port)
    PASS=$(get_config_password)
    SNI=$(get_config_sni)
    
    generate_all_configs
}

# ==================== 服务管理 ====================
service_manage() {
    echo ""
    echo "$(t 'service.title'):"
    echo "  1) $(t 'service.start')"
    echo "  2) $(t 'service.stop')"
    echo "  3) $(t 'service.restart')"
    echo "  4) $(t 'service.status')"
    echo ""
    read -rp "$(t 'menu.select') [1-4]: " svc_choice
    
    case $svc_choice in
        1) systemctl start hysteria-server && echo_success "$(t 'service.started')" || echo_error "$(t 'service.start_failed')" ;;
        2) systemctl stop hysteria-server && echo_success "$(t 'service.stopped')" || echo_error "$(t 'service.stop_failed')" ;;
        3) systemctl restart hysteria-server && echo_success "$(t 'service.restarted')" || echo_error "$(t 'service.restart_fail')" ;;
        4) systemctl status hysteria-server --no-pager ;;
        *) echo_error "$(t 'menu.invalid')" ;;
    esac
}

# ==================== 重新生成客户端配置 ====================
regenerate_configs() {
    if [[ ! -f "$HY2_CONFIG" ]]; then
        echo_error "$(t 'config.not_found')"
        return 1
    fi
    
    echo_step "$(t 'client.generating')"
    
    get_public_ip
    
    # 使用稳健的配置解析函数
    PORT=$(get_config_port)
    PASS=$(get_config_password)
    SNI=$(get_config_sni)
    OBFS_PASS=$(get_config_obfs)
    
    if [[ -z "$PORT" || -z "$PASS" || -z "$SNI" ]]; then
        echo_error "$(t 'config.incomplete')"
        return 1
    fi
    
    generate_all_configs
    echo_success "$(t 'client.done')"
    show_config_info
}

# ==================== 查看端口占用 ====================
show_port_usage() {
    echo_step_t "ports.checking"
    
    # 使用稳健的配置解析函数
    local port=""
    if [[ -f "$HY2_CONFIG" ]]; then
        port=$(get_config_port)
    fi
    
    echo ""
    echo -e "${Y}$(t 'ports.hy_ports'):${P}"
    if [[ -n "$port" ]]; then
        ss -tulnp 2>/dev/null | grep -E "hysteria|:${port}" || echo "  $(t 'ports.no_port')"
    else
        ss -tulnp 2>/dev/null | grep "hysteria" || echo "  $(t 'ports.no_port')"
    fi
    
    echo ""
    echo -e "${Y}$(t 'ports.hop_rules'):${P}"
    iptables -t nat -L HY2_HOP -n 2>/dev/null || echo "  $(t 'ports.no_hop')"
    
    echo ""
    echo -e "${Y}$(t 'ports.fw_rules'):${P}"
    if [[ -n "$port" ]]; then
        iptables -L INPUT -n 2>/dev/null | grep -E "udp.*dpt:${port}" || echo "  $(t 'ports.no_fw')"
    fi
}

# ==================== 卸载功能 ====================
uninstall() {
    echo_warning "$(t 'uninstall.confirm') [y/N]"
    read -rp "> " confirm
    
    [[ ! "$confirm" =~ ^[Yy]$ ]] && { echo_info "$(t 'common.cancelled')"; return 0; }
    
    echo ""
    echo_info "$(t 'uninstall.keep_config') [y/N]"
    read -rp "> " keep_config
    
    echo_step_t "uninstall.title"
    
    systemctl stop hysteria-server 2>/dev/null || true
    systemctl disable hysteria-server 2>/dev/null || true
    
    echo_info "$(t 'uninstall.cleaning_hop')"
    iptables -t nat -F HY2_HOP 2>/dev/null || true
    iptables -t nat -D PREROUTING -j HY2_HOP 2>/dev/null || true
    iptables -t nat -X HY2_HOP 2>/dev/null || true
    ip6tables -t nat -F HY2_HOP 2>/dev/null || true
    ip6tables -t nat -D PREROUTING -j HY2_HOP 2>/dev/null || true
    ip6tables -t nat -X HY2_HOP 2>/dev/null || true
    
    # 使用稳健的配置解析函数
    if [[ -f "$HY2_CONFIG" ]]; then
        local port
        port=$(get_config_port)
        if [[ -n "$port" ]]; then
            iptables -D INPUT -p udp --dport "$port" -j ACCEPT 2>/dev/null || true
            firewall-cmd --permanent --remove-port="${port}/udp" 2>/dev/null || true
            firewall-cmd --reload 2>/dev/null || true
            ufw delete allow "${port}/udp" 2>/dev/null || true
        fi
    fi
    
    netfilter-persistent save >/dev/null 2>&1 || true
    
    rm -f "$HY2_BINARY" "$HY2_SERVICE"
    
    if [[ "$keep_config" =~ ^[Yy]$ ]]; then
        echo_info "$(t 'uninstall.kept'): $HY2_DIR"
    else
        rm -rf "$HY2_DIR"
        echo_info "$(t 'uninstall.deleted')"
    fi
    
    systemctl daemon-reload
    
    echo_success "$(t 'uninstall.done')"
}

# ==================== 命令行参数解析 ====================
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --port)
                ARG_PORT="$2"
                shift 2
                ;;
            --password|--pass)
                ARG_PASS="$2"
                shift 2
                ;;
            --sni)
                ARG_SNI="$2"
                shift 2
                ;;
            --obfs)
                ARG_OBFS="$2"
                shift 2
                ;;
            --bw-up)
                ARG_BW_UP="$2"
                shift 2
                ;;
            --bw-down)
                ARG_BW_DOWN="$2"
                shift 2
                ;;
            --headless|-y)
                HEADLESS_MODE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            install|update|modify|switch|config|logs|uninstall)
                ACTION="$1"
                shift
                ;;
            *)
                echo_error "$(t 'error.unknown_arg'): $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    if [[ "$LANG_MODE" == "zh" ]]; then
        cat << EOF
Hysteria 2 安装脚本 v${SCRIPT_VERSION}

用法: $0 [命令] [选项]

命令:
  install     安装 Hysteria 2
  update      更新核心程序
  modify      修改配置
  switch      切换证书模式
  config      查看配置
  logs        查看日志
  uninstall   卸载

选项:
  --port PORT       指定端口
  --password PASS   指定密码
  --sni DOMAIN      指定 SNI 域名
  --obfs PASS       指定混淆密码
  --bw-up SPEED     指定上传带宽
  --bw-down SPEED   指定下载带宽
  --headless, -y    无交互模式
  --help, -h        显示帮助

示例:
  $0 install --port 443 --password mypass --headless
  $0 update
  $0 config
EOF
    else
        cat << EOF
Hysteria 2 Installation Script v${SCRIPT_VERSION}

Usage: $0 [command] [options]

Commands:
  install     Install Hysteria 2
  update      Update core binary
  modify      Modify configuration
  switch      Switch certificate mode
  config      View configuration
  logs        View logs
  uninstall   Uninstall

Options:
  --port PORT       Specify port
  --password PASS   Specify password
  --sni DOMAIN      Specify SNI domain
  --obfs PASS       Specify obfuscation password
  --bw-up SPEED     Specify upload bandwidth
  --bw-down SPEED   Specify download bandwidth
  --headless, -y    Non-interactive mode
  --help, -h        Show help

Examples:
  $0 install --port 443 --password mypass --headless
  $0 update
  $0 config
EOF
    fi
}

# ==================== 主函数 ====================
main() {
    ARG_PORT=""
    ARG_PASS=""
    ARG_SNI=""
    ARG_OBFS=""
    ARG_BW_UP=""
    ARG_BW_DOWN=""
    HEADLESS_MODE=false
    ACTION=""
    
    parse_args "$@"
    
    if [[ -z "$ACTION" && $# -eq 0 ]]; then
        show_menu
    else
        case ${ACTION:-$1} in
            install) install ;;
            update) update_hysteria ;;
            modify) modify_config ;;
            switch) switch_cert_mode ;;
            config) show_config_info ;;
            logs) journalctl -u hysteria-server -f ;;
            uninstall) uninstall ;;
            *) echo "Usage: $0 {install|update|modify|switch|config|logs|uninstall}"; show_help; exit 1 ;;
        esac
    fi
}

main "$@"
