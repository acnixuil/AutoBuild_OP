#!/bin/bash

# 设置变量
REPO_URL="https://github.com/immortalwrt/packages.git"
TARGET_PATH="$OPENWRT_PATH/feeds/packages/net/tailscale"

# 克隆指定目录并替换
git clone --depth=1 --branch master --filter=blob:none --sparse $REPO_URL temp_packages
cd temp_packages
git sparse-checkout set net/tailscale

# 替换目标文件夹
rm -rf "$TARGET_PATH"
mv net/tailscale "$TARGET_PATH"

# 清理临时文件夹
cd ..
rm -rf temp_packages

echo "Tailscale package updated successfully."