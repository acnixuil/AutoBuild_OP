#!/bin/bash

# --- 样式定义 ---
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

log() {
  echo -e "${BLUE}==>${RESET} $1"
}

section() {
  echo -e "\n${GREEN}==== $1 ====${RESET}"
}

DETECTED_VERSION="unknown"
VERSION_NUM=0

if [ -f "../include/version.mk" ]; then
    VERSION_RAW=$(grep -E '^VERSION_NUMBER:=\$\(if.*,' ../include/version.mk | head -n 1 | awk -F',' '{print $NF}' | tr -d ' )')
    DETECTED_VERSION=$(printf '%s' "$VERSION_RAW" | grep -oE '^[0-9]+\.[0-9]+')
    if [ -n "$DETECTED_VERSION" ]; then
        VERSION_NUM=$(echo "$DETECTED_VERSION" | tr -d '.')
    elif [ -n "$VERSION_RAW" ]; then
        DETECTED_VERSION="$VERSION_RAW"
        VERSION_NUM=9999
    fi
fi

if [ "$VERSION_NUM" -ge 9999 ]; then
    echo ">> 自动检测到当前源码的主版本为: ${DETECTED_VERSION}（非数字版本号，按最新源码处理）"
else
    echo ">> 自动检测到当前源码的主版本为: ${DETECTED_VERSION:-没匹配到数字版本}"
fi

find ../feeds/luci/ -name '*openclash*' | xargs rm -rf
find ../feeds/luci/ -name '*lucky*' | xargs rm -rf
find ../feeds/luci/ -name '*adguardhome*' | xargs rm -rf
find ../feeds/luci/ -name '*argon*' | xargs rm -rf

log "Updating Golang"
rm -rf ../feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 27.x ../feeds/packages/lang/golang

section "下载/更新插件"
git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  tmpdir="$(basename -s .git "$repourl")_tmp"
  git clone --depth=1 -b "$branch" --single-branch --filter=blob:none --sparse "$repourl" "$tmpdir"
  cd "$tmpdir" || exit 1
  git sparse-checkout set "$@"
  mv -f "$@" ../
  cd .. && rm -rf "$tmpdir"
}

git_sparse_clone dev https://github.com/vernesong/OpenClash luci-app-openclash
git clone --depth=1 --single-branch -b master https://github.com/acnixuil/luci-app-adguardhome.git luci-app-adguardhome
git clone --depth=1 --single-branch -b main https://github.com/sirpdboy/luci-app-lucky.git
git clone --depth=1 --single-branch -b master https://github.com/yhl452493373/luci-theme-argon luci-theme-argon
git clone --depth=1 --single-branch -b master https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config

log "添加 rtp2httpd"
find ./feeds ../feeds -name '*rtp2httpd*' -exec rm -rf {} + 2>/dev/null || true
git_sparse_clone main https://github.com/stackia/rtp2httpd.git openwrt-support
mv -f openwrt-support/rtp2httpd/Makefile.versioned openwrt-support/rtp2httpd/Makefile
mv -f openwrt-support/luci-app-rtp2httpd/Makefile.versioned openwrt-support/luci-app-rtp2httpd/Makefile

if [ "$VERSION_NUM" -ge 2410 ]; then
    echo ">> 当前固件版本 ($DETECTED_VERSION) >= 24.10，拉取高版本专属插件..."
 
    find ../ -name '*v2ray-geodata*' -exec rm -rf {} +
    find ../ -name '*mosdns*' -exec rm -rf {} +    
    find ../feeds/luci/ -name '*nikki*' | xargs rm -rf
    find ../feeds/luci/ -name '*diskman*' | xargs rm -rf
    
    git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-nikki.git nikki
    git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-momo.git momo
    git clone --depth=1 --single-branch -b main https://github.com/VizzleTF/luci-theme-footstrap.git luci-theme-footstrap
    git clone --depth=1 --single-branch -b main https://github.com/sbwml/luci-app-diskman luci-app-diskman
    git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns.git mosdns
    git clone --depth=1 --single-branch -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata
else
    echo ">> 当前固件版本 ($DETECTED_VERSION) < 24.10，跳过高版本专属插件的拉取。"
fi