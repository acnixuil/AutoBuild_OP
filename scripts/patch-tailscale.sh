#!/bin/bash

echo ">>> [tailscale] 开始处理 Tailscale 软件包..."

TARGET_PATH="$OPENWRT_PATH/feeds/packages/net/tailscale"
SOURCE_FILES_PATH="$OPENWRT_PATH/feeds/packages/net/tailscale/files"
INITD_DEST="$OPENWRT_PATH/files/etc/init.d"
REPO_URL="https://github.com/immortalwrt/packages.git"
LOCAL_VERSION=$(grep -oP '(?<=PKG_VERSION:=)\S+' "$TARGET_PATH/Makefile" 2>/dev/null)
REMOTE_VERSION=$(curl -s https://raw.githubusercontent.com/immortalwrt/packages/master/net/tailscale/Makefile | grep -oP '(?<=PKG_VERSION:=)\S+' | head -n 1)

echo "本地版本: ${LOCAL_VERSION:-未知}"
echo "远程版本: ${REMOTE_VERSION:-未知}"

if [ -n "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    if command -v dpkg >/dev/null 2>&1 && dpkg --compare-versions "$LOCAL_VERSION" lt "$REMOTE_VERSION"; then
        echo "发现新版本，正在更新 Tailscale package..."
        
        rm -rf temp_tailscale_pkg
        git clone --depth=1 --branch openwrt-24.10 --filter=blob:none --sparse $REPO_URL temp_tailscale_pkg
        
        cd temp_tailscale_pkg
        git sparse-checkout set net/tailscale

        rm -rf "$TARGET_PATH"
        mv net/tailscale "$OPENWRT_PATH/feeds/packages/net/"
        
        cd ..
        rm -rf temp_tailscale_pkg
        echo "Tailscale package 更新完成。"
    else
        echo "无需更新或环境不支持版本对比，跳过更新步骤。"
    fi
else
    echo "本地版本已是最新，无需更新。"
fi

echo "正在提取系统启动脚本..."

mkdir -p "$INITD_DEST"

if [ -f "$SOURCE_FILES_PATH/tailscale.init" ]; then
    cp -f "$SOURCE_FILES_PATH/tailscale.init" "$INITD_DEST/tailscale"
    chmod +x "$INITD_DEST/tailscale"
    echo "成功：已将 tailscale.init 复制到 files/etc/init.d/tailscale"
else
    echo "错误：在 $SOURCE_FILES_PATH 未找到 tailscale.init 源文件！"
    exit 1
fi

echo ">>> [tailscale] 处理完成"