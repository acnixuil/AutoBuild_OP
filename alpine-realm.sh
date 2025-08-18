#!/bin/sh
# 一键安装 Realm 中转服务（适用于 Alpine Linux）
# 运行前添加权限 chmod +x realm

set -e

REALM_DIR="/root/realm"
REALM_BIN="$REALM_DIR/realm"
REALM_CONF="$REALM_DIR/config.toml"
REALM_SERVICE="/etc/init.d/realm"
REALM_LOG="/var/log/realm.log"

echo "=== Realm 一键安装脚本启动 ==="

# 1. 创建目录
mkdir -p "$REALM_DIR"
chmod 755 "$REALM_DIR"

# 2. 获取最新 release 版本号
REALM_VERSION=$(curl -s https://api.github.com/repos/zhboner/realm/releases/latest | grep '"tag_name":' | cut -d'"' -f4)
REALM_RELEASE_URL="https://github.com/zhboner/realm/releases/download/${REALM_VERSION}"
echo "[*] 最新版本号: $REALM_VERSION"

# 3. 检查是否已存在 realm 二进制文件
if [ -f "$REALM_BIN" ]; then
    echo "[✔] 检测到已有 realm 二进制文件"
    chmod +x "$REALM_BIN"
else
    echo "[!] 未检测到 realm，准备下载"

    # 检查架构
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)   FILE="realm-x86_64-unknown-linux-musl.tar.gz" ;;
        aarch64)  FILE="realm-aarch64-unknown-linux-musl.tar.gz" ;;
        armv7l)   FILE="realm-armv7-unknown-linux-musleabihf.tar.gz" ;;
        *) echo "不支持的架构: $ARCH"; exit 1 ;;
    esac

    URL="${REALM_RELEASE_URL}/${FILE}"
    echo "下载 $URL"
    wget -O /tmp/realm.tar.gz "$URL"
    tar -xzf /tmp/realm.tar.gz -C "$REALM_DIR"
    rm -f /tmp/realm.tar.gz
    chmod +x "$REALM_BIN"
    echo "[✔] realm 已下载并设置可执行权限"
fi

# 4. 生成 config.toml
echo "[*] 开始生成配置文件：$REALM_CONF"

# 如果已存在，改名为 .bak
if [ -f "$REALM_CONF" ]; then
    BACKUP_FILE="${REALM_CONF}.$(date +%Y%m%d%H%M%S).bak"
    mv "$REALM_CONF" "$BACKUP_FILE"
    echo "[!] 已检测到旧配置文件，已备份至: $BACKUP_FILE"
fi

cat > "$REALM_CONF" <<EOF
[log]
level = "info"
file = "$REALM_LOG"

[network]
use_udp = true
EOF

while true; do
    echo "请输入本机监听端口:"
    read LPORT
    echo "请输入远程机 IP 或域名:"
    read RHOST
    echo "请输入远程机端口:"
    read RPORT

    cat >> "$REALM_CONF" <<EOF

[[endpoints]]
listen = "0.0.0.0:${LPORT}"
remote = "${RHOST}:${RPORT}"
EOF

    echo "是否继续添加转发端口？(y/n, 回车默认继续):"
    read ANSWER
    [ -z "$ANSWER" ] && ANSWER="y"
    if [ "$ANSWER" != "y" ]; then
        break
    fi
done

chmod 644 "$REALM_CONF"
echo "[✔] 配置文件已生成: $REALM_CONF"

# 5. 创建 OpenRC 服务脚本
echo "[*] 创建 OpenRC 服务脚本: $REALM_SERVICE"
cat > "$REALM_SERVICE" <<'EOF'
#!/sbin/openrc-run

name="realm"
description="Realm Port Forwarding Service"
command="/root/realm/realm"
command_args="-c /root/realm/config.toml"
output_log="/var/log/realm.log"
error_log="/var/log/realm.log"
pidfile="/var/run/${RC_SVCNAME}.pid"

command_background=true

depend() {
    need net
}
EOF

chmod 755 "$REALM_SERVICE"
rc-update add realm default

# 6. 创建日志文件
touch "$REALM_LOG"
chmod 644 "$REALM_LOG"
chown root:root "$REALM_LOG"

echo "[✔] 日志文件已创建: $REALM_LOG"

# 7. 启动服务
echo "=== 即将开始运行 realm ==="
rc-service realm restart

echo "=== 输出运行日志 (按 Ctrl+C 退出) ==="
tail -f "$REALM_LOG"