#!/bin/bash

echo ">>> 开始处理 Tailscale 预配置..."

# -----------------------------------------------------------------------------
# 1. 变量定义
# -----------------------------------------------------------------------------
TARGET_PATH="$OPENWRT_PATH/feeds/packages/net/tailscale"
SOURCE_FILES_PATH="$OPENWRT_PATH/feeds/packages/net/tailscale/files"
INITD_DEST="$OPENWRT_PATH/files/etc/init.d"
CONFIG_DEST="$OPENWRT_PATH/files/etc/config"
# 新增：确保 state_file 所在的目录存在，防止第一次启动报错
STATE_DIR_DEST="$OPENWRT_PATH/files/etc/tailscale"

REPO_URL="https://github.com/immortalwrt/packages.git"

# -----------------------------------------------------------------------------
# 2. 版本更新逻辑 (保持不变)
# -----------------------------------------------------------------------------
LOCAL_VERSION=$(grep -oP '(?<=PKG_VERSION:=)\S+' "$TARGET_PATH/Makefile" 2>/dev/null)
REMOTE_VERSION=$(curl -s https://raw.githubusercontent.com/immortalwrt/packages/master/net/tailscale/Makefile | grep -oP '(?<=PKG_VERSION:=)\S+' | head -n 1)

echo "本地版本: ${LOCAL_VERSION:-未知}"
echo "远程版本: ${REMOTE_VERSION:-未知}"

if [ -n "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    if command -v dpkg >/dev/null 2>&1 && dpkg --compare-versions "$LOCAL_VERSION" lt "$REMOTE_VERSION"; then
        echo "本地版本较旧，开始更新 Tailscale package..."
        rm -rf temp_packages
        git clone --depth=1 --branch openwrt-24.10 --filter=blob:none --sparse $REPO_URL temp_packages
        cd temp_packages
        git sparse-checkout set net/tailscale
        rm -rf "$TARGET_PATH"
        mv net/tailscale "$OPENWRT_PATH/feeds/packages/net/"
        cd ..
        rm -rf temp_packages
        echo "Tailscale package 更新完成。"
    else
        echo "无需更新或环境不支持版本对比。"
    fi
else
    echo "本地版本已是最新。"
fi

# -----------------------------------------------------------------------------
# 3. 部署启动脚本 (直接复制原版)
# -----------------------------------------------------------------------------
echo "正在部署启动脚本..."
mkdir -p "$INITD_DEST"

if [ -f "$SOURCE_FILES_PATH/tailscale.init" ]; then
    cp -f "$SOURCE_FILES_PATH/tailscale.init" "$INITD_DEST/tailscale"
    chmod +x "$INITD_DEST/tailscale"
else
    echo "警告：未找到 tailscale.init 源文件！"
fi

# -----------------------------------------------------------------------------
# 4. 生成 UCI 配置文件 (完全匹配官方格式 + 修改端口)
# -----------------------------------------------------------------------------
echo "正在生成 UCI 配置文件 (端口设为 61422)..."
mkdir -p "$CONFIG_DEST"
mkdir -p "$STATE_DIR_DEST"  # 预创建 /etc/tailscale 目录

# 使用你提供的官方模板，仅修改 option port
cat > "$CONFIG_DEST/tailscale" <<EOF
config settings 'settings'
	option log_stderr '1'
	option log_stdout '1'
	option port '61422'
	option state_file '/etc/tailscale/tailscaled.state'
	option fw_mode 'nftables'
EOF

echo ">>> Tailscale 预处理完成：已配置为 nftables 模式且端口为 61422"