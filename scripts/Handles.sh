#!/bin/bash

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

PKG_PATCH="$GITHUB_WORKSPACE/openwrt/package"

# OpenClash
if [ -d "./luci-app-openclash" ]; then
  section "处理 OpenClash 数据"
  CORE_TYPE=$CLASH_KERNEL
  CORE_META="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"
  GEO_IP="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
  GEO_SITE="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
  GEO_MMDB="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb"
  UI="https://github.com/MetaCubeX/metacubexd/releases/download/v1.151.0/compressed-dist.tgz"

  rm -rf ./luci-app-openclash/root/usr/share/openclash/ui/metacubexd/*
  curl -sL $UI | tar -xz -C ./luci-app-openclash/root/usr/share/openclash/ui/metacubexd

  cd ./luci-app-openclash/root/etc/openclash/
  curl -sL -o Country.mmdb $GEO_MMDB && log "Country.mmdb 已下载"
  curl -sL -o GeoSite.dat $GEO_SITE && log "GeoSite.dat 已下载"
  curl -sL -o GeoIP.dat $GEO_IP && log "GeoIP.dat 已下载"

  mkdir ./core && cd ./core
  curl -sL -o meta.tar.gz $CORE_META && tar -zxf meta.tar.gz && mv -f clash clash_meta && log "核心 meta 已完成"

  chmod +x ./* && rm -f ./*.gz
  log "OpenClash 数据已更新"
  cd "$PKG_PATCH"
fi

# nikki
if [ -d "./nikki" ]; then
  section "处理 nikki 插件"
  GEO_IP="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
  GEO_SITE="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
  GEO_MMDB="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb"
  UI="https://github.com/MetaCubeX/metacubexd/releases/download/v1.151.0/compressed-dist.tgz"

  mkdir -p ./nikki/luci-app-nikki/root/etc/nikki/run/ui
  cd ./nikki/luci-app-nikki/root/etc/nikki/run

  if [[ "$REPO_URL" != *"VIKINGYFY"* && "$REPO_URL" != *"LiBwrt"* && "$REPO_URL" != *"mt798x"* ]]; then
    log "REPO_URL 不包含 VIKINGYFY 或 LiBwrt，开始下载 nikki 所需数据文件"
    curl -sL -o ASN.mmdb $GEO_MMDB && log "ASN.mmdb 已下载"
    curl -sL -o GeoSite.dat $GEO_SITE && log "GeoSite.dat 已下载"
    curl -sL -o GeoIP.dat $GEO_IP && log "GeoIP.dat 已下载"
  else
    log "REPO_URL 包含 VIKINGYFY 或 LiBwrt，跳过 nikki 数据文件下载"
  fi

  curl -sL $UI | tar -xz -C ./ui && log "UI 资源已更新"
  cd "$PKG_PATCH"
fi

# AdGuardHome
if [ -d "./luci-app-adguardhome" ]; then
  section "处理 AdGuardHome"
  AGH_PATCH="luci-app-adguardhome/root/usr/bin/AdGuardHome"
  mkdir -p ./$AGH_PATCH

  AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep /AdGuardHome_linux_${CLASH_KERNEL} | awk -F '"' '{print $4}')
  wget -qO- $AGH_CORE | tar xOvz > ./$AGH_PATCH/AdGuardHome

  chmod +x ./$AGH_PATCH/AdGuardHome
  log "AdGuardHome 数据已更新"
  cd "$PKG_PATCH"
fi

# 替换 Argon 壁纸
if [ -d "./luci-theme-argon" ]; then
  section "替换 Argon 背景与样式"
  cp -f $GITHUB_WORKSPACE/images/bg1.jpg luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
	sed -i "/font-weight:/ { /important/! { /\/\*/! s/:.*/: var(--font-weight);/ } }" $(find luci-theme-argon -type f -iname "*.css")
	sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'600'/'normal'/" luci-app-argon-config/root/etc/config/argon
  sed -i '/<footer.*>/,/<\/footer>/d' luci-theme-argon/luasrc/view/themes/argon/footer.htm
  sed -i '/<footer.*>/,/<\/footer>/d' luci-theme-argon/luasrc/view/themes/argon/footer_login.htm
  log "Argon 样式处理完成"
  cd "$PKG_PATCH"
fi

# 修改 amlogic 配置
if [ -d "./luci-app-amlogic" ]; then
  section "处理 Amlogic 配置"
  CONFIG_FILE="./luci-app-amlogic/luci-app-amlogic/root/etc/config/amlogic"
  sed -i "s/ARMv8/ARMv8/g" "$CONFIG_FILE"
  log "Amlogic 配置已更新"
  cd "$PKG_PATCH"
fi

# 其他补丁和重命名
section "修补系统配置"
cd $GITHUB_WORKSPACE/openwrt/
sed -i '/\/etc\/init\.d\/tailscale/d;/\/etc\/config\/tailscale/d;' feeds/packages/net/tailscale/Makefile
sed -i 's/vpn/services/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
sed -i 's/msgstr "UPnP IGD 和 PCP\/NAT-PMP"/msgstr "UPnP"/' feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po

section "脚本处理完成"
log "所有数据和配置处理已完成 ✔"
exit 0
