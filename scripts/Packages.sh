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

# --- 1. 清理旧包 ---
find ../ -name '*v2ray-geodata*' -exec rm -rf {} +
find ../ -name '*mosdns*' -exec rm -rf {} +
find ../feeds/luci/ -name '*passwall*' | xargs rm -rf
find ../feeds/luci/ -name '*nikki*' | xargs rm -rf
find ../feeds/luci/ -name '*openclash*' | xargs rm -rf
find ../feeds/luci/ -name '*lucky*' | xargs rm -rf
find ../feeds/luci/ -name '*adguardhome*' | xargs rm -rf
find ../feeds/luci/ -name '*argon*' | xargs rm -rf

log "Updating Golang to 25.x..."
rm -rf ../feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x ../feeds/packages/lang/golang

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

git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns.git luci-app-mosdns
git clone --depth=1 --single-branch -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata

git clone --depth=1 --single-branch -b master https://github.com/acnixuil/luci-app-adguardhome.git luci-app-adguardhome
git clone --depth=1 --single-branch -b main https://github.com/sirpdboy/luci-app-lucky.git

git clone --depth=1 --single-branch -b master https://github.com/yhl452493373/luci-theme-argon luci-theme-argon
git clone --depth=1 --single-branch -b master https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config
git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-nikki.git nikki
git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-momo.git momo

# git clone --depth=1 --single-branch -b master https://github.com/Tokisaki-Galaxy/luci-app-tailscale-community.git luci-app-tailscale-community

section "完成插件列表处理"