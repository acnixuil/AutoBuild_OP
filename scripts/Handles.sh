#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

log() {
  echo -e "${BLUE}==>${RESET} $1"
}

section() {
  echo "" 
  echo -e "${GREEN}==== $1 ====${RESET}"
}

PKG_PATCH="$GITHUB_WORKSPACE/openwrt/package"

cd "$PKG_PATCH" || exit 1

UI_URL="https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages-misans-only.zip"
GEO_IP="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
GEO_SITE="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
GEO_MMDB="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb"

download_ui() {
  local target_dir="$1"
  local tmp_dir
  tmp_dir=$(mktemp -d)
  log "正在下载 UI 资源..."
  
  if curl -sL "$UI_URL" -o "$tmp_dir/ui.zip" && unzip -q "$tmp_dir/ui.zip" -d "$tmp_dir"; then
    rm -rf "$target_dir"/*
    mkdir -p "$target_dir"
    # 将解压后的内部文件拷贝到目标目录
    cp -r "$tmp_dir"/*/* "$target_dir"/
    log "UI 资源已更新 -> $target_dir ✔"
  else
    log "❌ 错误: UI 资源下载或解压失败"
  fi
  rm -rf "$tmp_dir"
}

download_geo_files() {
  curl -sL -o GeoIP.dat "$GEO_IP" && log "GeoIP.dat 已下载 ✔" || log "❌ 错误: GeoIP.dat 下载失败"
  curl -sL -o GeoSite.dat "$GEO_SITE" && log "GeoSite.dat 已下载 ✔" || log "❌ 错误: GeoSite.dat 下载失败"
  curl -sL -o Country.mmdb "$GEO_MMDB" && log "Country.mmdb 已下载 ✔" || log "❌ 错误: Country.mmdb 下载失败"
}

if [ -d "./luci-app-openclash" ]; then
  section "处理 OpenClash 数据"
  CORE_TYPE=$ARCH
  CORE_META="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"

  download_ui "./luci-app-openclash/root/usr/share/openclash/ui/metacubexd"

  cd ./luci-app-openclash/root/etc/openclash/
  download_geo_files

  log "正在下载 OpenClash 核心 meta: $CORE_META"
  TMP_DIR=$(mktemp -d)
  
  if curl -sL "$CORE_META" | tar -xzf - -C "$TMP_DIR"; then
    if [ -f "$TMP_DIR/clash" ]; then
      mkdir -p ./core
      mv -f "$TMP_DIR/clash" "./core/clash_meta"
      chmod +x "./core/clash_meta"
      log "OpenClash 核心 meta 已完成 ✔"
    else
      log "❌ 错误: 解压成功，但在压缩包内未找到 clash 二进制文件"
    fi
  else
    log "❌ 错误: OpenClash 核心下载或解压过程失败"
  fi
  
  rm -rf "$TMP_DIR"
  cd "$PKG_PATCH"
fi

if [ -d "./nikki" ]; then
  section "处理 nikki 插件"
  UI_TARGET="./nikki/luci-app-nikki/root/etc/nikki/run/ui"
  download_ui "$UI_TARGET"

  cd ./nikki/luci-app-nikki/root/etc/nikki/run
  if [[ "$REPO_URL" != *"VIKINGYFY"* && "$REPO_URL" != *"LiBwrt"* && "$REPO_URL" != *"mt798x"* ]]; then
    log "REPO_URL 不包含特定标识，开始下载 nikki 数据文件..."
    curl -sL -o ASN.mmdb "$GEO_MMDB" && log "ASN.mmdb 已下载 ✔" || log "❌ 错误: ASN.mmdb 下载失败"
    curl -sL -o GeoSite.dat "$GEO_SITE" && log "GeoSite.dat 已下载 ✔" || log "❌ 错误: GeoSite.dat 下载失败"
    curl -sL -o GeoIP.dat "$GEO_IP" && log "GeoIP.dat 已下载 ✔" || log "❌ 错误: GeoIP.dat 下载失败"
  else
    log "REPO_URL 包含特定标识，跳过 nikki 数据文件下载"
  fi
  cd "$PKG_PATCH"
fi

if [ -d "./momo" ]; then
  section "处理 momo 插件"
  mkdir -p ./momo/luci-app-momo/root/etc/momo/run
  ln -sf /etc/nikki/run/ui ./momo/luci-app-momo/root/etc/momo/run/ui
  log "momo 面板链接已创建 ✔"
  cd "$PKG_PATCH"
fi

if [ -d "./luci-app-adguardhome" ]; then
  section "处理 AdGuardHome"
  AGH_DIR="luci-app-adguardhome/root/usr/bin"
  mkdir -p "./$AGH_DIR"

  # 抓取对应架构的下载链接
  AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep "browser_download_url" | grep -oE "https://[^\"]*AdGuardHome_linux_${ARCH}\.tar\.gz" | head -n 1)

  if [ -n "$AGH_CORE" ]; then
    log "正在下载 AdGuardHome 核心: $AGH_CORE"
    TMP_DIR=$(mktemp -d)
    
    # 将压缩包完整解压到临时目录，不使用容易报错的 strip-components
    if curl -sL "$AGH_CORE" | tar -xzf - -C "$TMP_DIR"; then
      
      # 使用 find 命令在临时目录中寻找名为 AdGuardHome 的文件（无视它的目录层级）
      AGH_BIN=$(find "$TMP_DIR" -type f -name "AdGuardHome" | head -n 1)
      
      if [ -n "$AGH_BIN" ] && [ -f "$AGH_BIN" ]; then
        # 找到文件后，移动到目标目录并赋予执行权限
        mv -f "$AGH_BIN" "./$AGH_DIR/AdGuardHome"
        chmod +x "./$AGH_DIR/AdGuardHome"
        log "AdGuardHome 数据已更新 ✔"
      else
        log "❌ 错误: 解压成功，但在压缩包内未找到 AdGuardHome 二进制文件"
      fi
    else
      log "❌ 错误: AdGuardHome 核心下载或解压过程失败"
    fi
    
    # 清理临时目录
    rm -rf "$TMP_DIR"
  else
    log "❌ 错误: 未能抓取到对应架构 (${ARCH}) 的 AdGuardHome 下载链接，请检查变量是否匹配"
  fi
  
  cd "$PKG_PATCH"
fi

section "处理 singbox 核心"
rm -rf ../feeds/packages/net/sing-box
mkdir -p ./sing-box

log "正在配置 ${ARCH} 架构的 singbox Makefile"

if [ "$ARCH" = "arm64" ]; then
    SINGBOX_URL="https://singbox-custom-dl.pages.dev/sing-box-reF1nd-stable-arm64-upx.tar.gz"
    log "检测到 arm64，替换 singbox 内核为 upx 压缩版本"
else
    SINGBOX_URL="https://singbox-custom-dl.pages.dev/sing-box-reF1nd-stable-${ARCH}.tar.gz"
fi

cat > ./sing-box/Makefile << EOF
include \$(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.0.0
PKG_RELEASE:=\$(shell date +%Y%m%d)

include \$(INCLUDE_DIR)/package.mk

define Package/sing-box
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Sing-box (Custom Binary from CF Pages)
  DEPENDS:=+ca-bundle +kmod-tun
endef

define Package/sing-box/description
  Downloads pre-compiled sing-box binary from Cloudflare Pages.
endef

define Build/Prepare
	mkdir -p \$(PKG_BUILD_DIR)
endef

define Build/Compile
	echo "Downloading sing-box from ${SINGBOX_URL}..."
	curl -L -k -o \$(PKG_BUILD_DIR)/sing-box.tar.gz "${SINGBOX_URL}"
	tar -xzvf \$(PKG_BUILD_DIR)/sing-box.tar.gz -C \$(PKG_BUILD_DIR)
endef

define Package/sing-box/install
	\$(INSTALL_DIR) \$(1)/usr/bin
	\$(INSTALL_BIN) \$(PKG_BUILD_DIR)/sing-box \$(1)/usr/bin/sing-box
endef

\$(eval \$(call BuildPackage,sing-box))
EOF

log "完成 singbox Makefile 生成 ✔"
cd "$PKG_PATCH"

section "处理 mihomo 核心"
if [ "$ARCH" = "arm64" ]; then
    MIHOMO_URL=$(curl -sL "https://api.github.com/repos/acnixuil/AutoBuild_OP/releases/tags/upx-binary" | grep -oE "https://[^\"]*mihomo-stable[^\"]*linux-arm64-upx\.tar\.gz" | head -n 1)
    if [ -n "$MIHOMO_URL" ]; then
        MAKEFILE_PATH="./nikki/nikki/Makefile"
        if [ ! -f "$MAKEFILE_PATH" ]; then
            MAKEFILE_PATH="./nikki/nikki/makefile"
        fi
        
        if [ -f "$MAKEFILE_PATH" ]; then
            sed -i \
                -e '/^PKG_SOURCE/d' \
                -e '/^PKG_MIRROR_HASH/d' \
                -e '/^PKG_BUILD_/d' \
                -e '/^GO_PKG/d' \
                -e '/golang-package.mk/d' \
                -e '/GoBinPackage/d' \
                -e '/GoPackage\/Package\/Install\/Bin/d' \
                -e 's|\$(PKG_INSTALL_DIR)/usr/bin/mihomo|\$(PKG_BUILD_DIR)/mihomo|g' \
                -e '/define Build\/Prepare/,/endef/d' \
                -e '/\$(eval \$(call BuildPackage,nikki))/d' \
                "$MAKEFILE_PATH"

            cat >> "$MAKEFILE_PATH" << EOF

define Build/Prepare
	mkdir -p \$(PKG_BUILD_DIR)
endef

define Build/Compile
	echo "Downloading mihomo from $MIHOMO_URL..."
	curl -L -k -o \$(PKG_BUILD_DIR)/mihomo.tar.gz "$MIHOMO_URL"
	tar -xzvf \$(PKG_BUILD_DIR)/mihomo.tar.gz -C \$(PKG_BUILD_DIR)
	mv \$(PKG_BUILD_DIR)/nikki \$(PKG_BUILD_DIR)/mihomo 2>/dev/null || true
	chmod +x \$(PKG_BUILD_DIR)/mihomo
endef

\$(eval \$(call BuildPackage,nikki))
EOF
            log "完成替换 nikki/mihomo 核心配置 ✔"
        else
            log "❌ 错误: 未能在路径找到 nikki Makefile"
        fi
    else
        log "❌ 错误: 未能抓取到 mihomo-stable 下载链接"
    fi
else
    log "跳过 mihomo 核心替换 (非 arm64 架构)"
fi
cd "$PKG_PATCH"

if [ -d "./luci-theme-argon" ]; then
  section "替换 Argon 背景与样式"
  cp -f $GITHUB_WORKSPACE/images/bg1.jpg luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
  
  # 加入 find 是否找到文件的保护
  CSS_FILES=$(find luci-theme-argon -type f -iname "*.css")
  if [ -n "$CSS_FILES" ]; then
    sed -i "/font-weight:/ { /important/! { /\/\*/! s/:.*/: var(--font-weight);/ } }" $CSS_FILES
  fi
  
  if [ -f "luci-app-argon-config/root/etc/config/argon" ]; then
    sed -i "s/primary '.*'/primary '#31a1a1'/; s/'0.2'/'0.5'/; s/'600'/'normal'/" luci-app-argon-config/root/etc/config/argon
  fi
  log "Argon 样式处理完成 ✔"
  cd "$PKG_PATCH"
fi

section "修补系统配置"
cd $GITHUB_WORKSPACE/openwrt/

ZT_MENU="feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json"
UPNP_PO="feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po"

if [ -f "$ZT_MENU" ]; then
  sed -i 's/vpn/services/g' "$ZT_MENU"
  log "ZeroTier 菜单路径已修补 ✔"
fi

if [ -f "$UPNP_PO" ]; then
  sed -i 's/msgstr "UPnP IGD 和 PCP\/NAT-PMP"/msgstr "UPnP"/' "$UPNP_PO"
  log "UPnP 翻译已修补 ✔"
fi

section "配置 Custom Tailscale (预编译精简版)"

TS_MAKEFILE="../feeds/packages/net/tailscale/Makefile"

if [ -f "$TS_MAKEFILE" ]; then
  log "正在获取 Tailscale 最新版本信息..."
  
  # 使用兼容性更好的 awk 方式提取 JSON 中的 tag_name
  TS_VERSION=$(curl -sL https://api.github.com/repos/admonstrator/glinet-tailscale-updater/releases/latest | grep '"tag_name":' | head -n 1 | awk -F '"' '{print $4}')

  if [ -n "$TS_VERSION" ]; then
    log "获取到 Tailscale 精简版最新版本: ${TS_VERSION}"
    log "当前设备架构: ${ARCH}"

    TS_URL="https://github.com/admonstrator/glinet-tailscale-updater/releases/download/${TS_VERSION}/tailscaled-linux-${ARCH}"
    log "目标下载地址: ${TS_URL}"

    # 执行替换前，确保删除逻辑涵盖了原版 Makefile 中的所有 Go 语言编译特征
    sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=${TS_VERSION#v}/g" "$TS_MAKEFILE"
    sed -i '/PKG_HASH:=/d' "$TS_MAKEFILE"
    sed -i '/golang-package.mk/d' "$TS_MAKEFILE"
    sed -i '/GO_PKG/d' "$TS_MAKEFILE"
    
    # 截断 Build/Compile 及其后的所有内容
    sed -i '/define Build\/Compile/,$d' "$TS_MAKEFILE"

    # 注入自定义的下载与安装逻辑
    cat >> "$TS_MAKEFILE" << EOF
define Build/Compile
	echo "Downloading pre-compiled tailscale from ${TS_URL}"
	curl -L -k -o \$(PKG_BUILD_DIR)/tailscaled "${TS_URL}"
	chmod +x \$(PKG_BUILD_DIR)/tailscaled
endef

define Package/tailscale/install
	\$(INSTALL_DIR) \$(1)/usr/sbin \$(1)/etc/init.d \$(1)/etc/config
	\$(INSTALL_BIN) \$(PKG_BUILD_DIR)/tailscaled \$(1)/usr/sbin/tailscaled
	\$(LN) tailscaled \$(1)/usr/sbin/tailscale
	\$(INSTALL_BIN) ./files/tailscale.init \$(1)/etc/init.d/tailscale
	\$(INSTALL_DATA) ./files/tailscale.conf \$(1)/etc/config/tailscale
endef

\$(eval \$(call BuildPackage,tailscale))
EOF

    log "Tailscale Makefile 修改完成 ✔"
  else
    log "❌ 错误: 未能获取到 Tailscale 最新版本号，请检查网络或 GitHub API 速率限制"
  fi
else
  log "❌ 错误: 未找到 Tailscale Makefile ($TS_MAKEFILE)，请检查 feeds 是否已正确更新"
fi

section "脚本处理完成"
log "所有数据和配置处理已完成 ✔"
exit 0