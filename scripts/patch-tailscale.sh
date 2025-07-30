#!/bin/bash

echo "开始补全tailscale配置文件"

# 路径变量
TARGET_PATH="$OPENWRT_PATH/feeds/packages/net/tailscale"
INIT_PATH="$OPENWRT_PATH/feeds/packages/net/tailscale/files"
INITD_PATH="$OPENWRT_PATH/files/etc/init.d"
REPO_URL="https://github.com/immortalwrt/packages.git"

# 获取本地版本号
LOCAL_VERSION=$(grep -oP '(?<=PKG_VERSION:=)\S+' "$TARGET_PATH/Makefile")
# 获取远程版本号（从GitHub上的文件中读取）
REMOTE_VERSION=$(curl -s https://raw.githubusercontent.com/immortalwrt/packages/master/net/tailscale/Makefile | grep -oP '(?<=PKG_VERSION:=)\S+' | head -n 1)

# 比较版本号
if dpkg --compare-versions "$LOCAL_VERSION" lt "$REMOTE_VERSION"; then
    echo "本地版本小于远程版本，开始更新Tailscale package"

    # 克隆并替换
    git clone --depth=1 --branch openwrt-24.10 --filter=blob:none --sparse $REPO_URL temp_packages
    cd temp_packages
    git sparse-checkout set net/tailscale

    # 替换目标文件夹
    rm -rf "$TARGET_PATH"
    mv net/tailscale "$TARGET_PATH"

    # 清理临时文件夹
    cd ..
    rm -rf temp_packages

    echo "Tailscale package updated successfully."
else
    echo "本地版本已是最新或已大于远程版本，跳过更新"
fi

# 创建必要的目录
mkdir -p $INITD_PATH

# 复制并设置权限
cp -f $INIT_PATH/tailscale.init $INITD_PATH/tailscale
sed -i 's/\(config_get port "settings" port \)[0-9]\+/\1 61422/' "$INITD_PATH/tailscale"
chmod +x $INITD_PATH/tailscale
echo "已完成修补"