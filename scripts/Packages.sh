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
    DETECTED_VERSION=$(grep -E '^VERSION_NUMBER:=\$\(if.*,' ../include/version.mk | awk -F',' '{print $3}' | tr -d ')' | grep -oE '^[0-9]+\.[0-9]+')
    if [ -n "$DETECTED_VERSION" ]; then
        VERSION_NUM=$(echo "$DETECTED_VERSION" | tr -d '.')
    fi
fi

echo ">> 自动检测到当前源码的主版本为: ${DETECTED_VERSION:-"未匹配到数字版本"}"

find ../feeds/luci/ -name '*openclash*' | xargs rm -rf
find ../feeds/luci/ -name '*lucky*' | xargs rm -rf
find ../feeds/luci/ -name '*adguardhome*' | xargs rm -rf
find ../feeds/luci/ -name '*argon*' | xargs rm -rf

log "Updating Golang"
rm -rf ../feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 26.x ../feeds/packages/lang/golang

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

if [ "$VERSION_NUM" -ge 2410 ]; then
    echo ">> 当前固件版本 ($DETECTED_VERSION) >= 24.10，拉取高版本专属插件..."
 
    find ../ -name '*v2ray-geodata*' -exec rm -rf {} +
    find ../ -name '*mosdns*' -exec rm -rf {} +    
    find ../feeds/luci/ -name '*nikki*' | xargs rm -rf
    find ../feeds/luci/ -name '*diskman*' | xargs rm -rf
    
    git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-nikki.git nikki
    git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-momo.git momo
    git clone --depth=1 --single-branch -b main https://github.com/sbwml/luci-app-diskman luci-app-diskman
    git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns.git mosdns
    git clone --depth=1 --single-branch -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata
else
    echo ">> 当前固件版本 ($DETECTED_VERSION) < 24.10，跳过高版本专属插件的拉取。"
fi