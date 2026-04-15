#!/bin/bash

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# 全局变量优先声明，确保所有函数都能正确读取
PKG_PATCH="$GITHUB_WORKSPACE/openwrt/package"

log() {
  echo -e "${BLUE}==>${RESET} $1"
}

section() {
  echo "" 
  echo -e "${GREEN}==== $1 ====${RESET}"
  # 每个区块开始前，防御性复位一次基准路径
  cd "$PKG_PATCH" || exit 1
}

# 首次进入基准路径
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
  # ln -sf /etc/nikki/run/ui ./momo/luci-app-momo/root/etc/momo/run/ui
  UI_TARGET="./momo/luci-app-momo/root/etc/momo/run/ui"
  download_ui "$UI_TARGET"
  log "momo 面板链接已创建 ✔"
  cd "$PKG_PATCH"
fi

if [ -d "./luci-app-adguardhome" ]; then
  section "处理 AdGuardHome"
  AGH_DIR="luci-app-adguardhome/root/usr/bin"
  mkdir -p "./$AGH_DIR"

  AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep "browser_download_url" | grep -oE "https://[^\"]*AdGuardHome_linux_${ARCH}\.tar\.gz" | head -n 1)

  if [ -n "$AGH_CORE" ]; then
    log "正在下载 AdGuardHome 核心: $AGH_CORE"
    TMP_DIR=$(mktemp -d)
    
    if curl -sL "$AGH_CORE" | tar -xzf - -C "$TMP_DIR"; then
      AGH_BIN=$(find "$TMP_DIR" -type f -name "AdGuardHome" | head -n 1)
      
      if [ -n "$AGH_BIN" ] && [ -f "$AGH_BIN" ]; then
        mv -f "$AGH_BIN" "./$AGH_DIR/AdGuardHome"
        chmod +x "./$AGH_DIR/AdGuardHome"
        log "AdGuardHome 数据已更新 ✔"
      else
        log "❌ 错误: 解压成功，但在压缩包内未找到 AdGuardHome 二进制文件"
      fi
    else
      log "❌ 错误: AdGuardHome 核心下载或解压过程失败"
    fi
    rm -rf "$TMP_DIR"
  else
    log "❌ 错误: 未能抓取到对应架构 (${ARCH}) 的 AdGuardHome 下载链接，请检查变量是否匹配"
  fi
  cd "$PKG_PATCH"
fi

# Custom Sing-box
section "配置 Custom Sing-box"

# 判断架构是否在支持列表中 (arm64 或 amd64)
if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "amd64" ]; then
  rm -rf ../feeds/packages/net/sing-box
  mkdir -p ./sing-box

  log "Generating Sing-box Makefile for arch: ${ARCH}"

  # 根据架构动态匹配下载链接
  if [ "$ARCH" = "arm64" ]; then
    SINGBOX_URL="https://singbox-custom-dl.pages.dev/sing-box-reF1nd-stable-${ARCH}-upx.tar.gz"
    log "检测到 arm64，使用带有 -upx 尾缀的极限压缩内核"
  elif [ "$ARCH" = "amd64" ]; then
    SINGBOX_URL="https://singbox-custom-dl.pages.dev/sing-box-reF1nd-stable-${ARCH}.tar.gz"
    log "检测到 amd64，使用无压缩的原版内核"
  fi

  # 生成 Makefile，直接利用外层 Shell 的 ${ARCH} 和 ${SINGBOX_URL} 变量注入
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
	echo "Downloading sing-box for ${ARCH}..."
	curl -L -k -o \$(PKG_BUILD_DIR)/sing-box.tar.gz "${SINGBOX_URL}"
	tar -xzvf \$(PKG_BUILD_DIR)/sing-box.tar.gz -C \$(PKG_BUILD_DIR)
	# 清理压缩包并智能重命名为 sing-box，防止后续 install 找不到文件
	rm -f \$(PKG_BUILD_DIR)/sing-box.tar.gz
	SB_BIN=\$\$(find \$(PKG_BUILD_DIR) -type f -iname "*sing*box*" | head -n 1); \\
	[ -n "\$\$SB_BIN" ] && mv -f "\$\$SB_BIN" \$(PKG_BUILD_DIR)/sing-box || true
	chmod +x \$(PKG_BUILD_DIR)/sing-box
endef

define Package/sing-box/install
	\$(INSTALL_DIR) \$(1)/usr/bin
	\$(INSTALL_BIN) \$(PKG_BUILD_DIR)/sing-box \$(1)/usr/bin/sing-box
endef

\$(eval \$(call BuildPackage,sing-box))
EOF

  log "Sing-box 配置完成 ✔"
else
  # 如果既不是 arm64 也不是 amd64，跳过执行
  log "跳过 Sing-box 配置 (当前架构 $ARCH 不匹配预设规则)"
fi

# 无论上述执行与否，最后统一安全退回基础路径
cd "$PKG_PATCH" || exit 1

section "替换 mihomo-meta 核心"

if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "amd64" ]; then
    
    if [ "$ARCH" = "arm64" ]; then
        DOWNLOAD_KEY="linux-arm64-upx"
    else
        DOWNLOAD_KEY="linux-amd64"
    fi

    MIHOMO_URL=$(curl -sL "https://api.github.com/repos/acnixuil/AutoBuild_OP/releases/tags/upx-binary" | grep -oE "https://[^\"]*mihomo-alpha[^\"]*${DOWNLOAD_KEY}\.tar\.gz" | head -n 1)
    
    if [ -n "$MIHOMO_URL" ]; then
        MAKEFILE_PATH=$(find ./ -path "*/mihomo-meta/Makefile" | head -n 1)
        
        if [ -f "$MAKEFILE_PATH" ]; then
            sed -i \
                -e '/^PKG_SOURCE/d' \
                -e '/^PKG_MIRROR_HASH/d' \
                -e '/^PKG_BUILD_/d' \
                -e '/^GO_PKG/d' \
                -e '/golang-package.mk/d' \
                -e '/GoBinPackage/d' \
                -e '/define Package\/mihomo-meta\/install/,/endef/d' \
                -e '/define Build\/Prepare/,/endef/d' \
                -e '/\$(eval \$(call BuildPackage,mihomo-meta))/d' \
                "$MAKEFILE_PATH"

            cat >> "$MAKEFILE_PATH" << EOF

define Build/Prepare
	mkdir -p \$(PKG_BUILD_DIR)
endef

define Build/Compile
	curl -L -k -o \$(PKG_BUILD_DIR)/mihomo.tar.gz "$MIHOMO_URL"
	tar -xzvf \$(PKG_BUILD_DIR)/mihomo.tar.gz -C \$(PKG_BUILD_DIR)
	chmod +x \$(PKG_BUILD_DIR)/mihomo
endef

define Package/mihomo-meta/install
	\$(INSTALL_DIR) \$(1)/usr/libexec
	\$(INSTALL_BIN) \$(PKG_BUILD_DIR)/mihomo \$(1)/usr/libexec/mihomo
endef

\$(eval \$(call BuildPackage,mihomo-meta))
EOF
            log "mihomo-meta 核心替换成功"
        else
            log "未能找到 mihomo-meta Makefile"
        fi
    else
        log "未能抓取到下载链接"
    fi
else
    log "当前架构不匹配，跳过执行"
fi
cd "$PKG_PATCH"

section "配置 Custom Tailscale (预编译精简版)"

TS_MAKEFILE="../feeds/packages/net/tailscale/Makefile"

if [ -f "$TS_MAKEFILE" ]; then
  log "正在获取 Tailscale 最新版本信息..."
  
  TS_VERSION=$(curl -sL https://api.github.com/repos/admonstrator/glinet-tailscale-updater/releases/latest | grep '"tag_name":' | head -n 1 | awk -F '"' '{print $4}' || true)

  if [ -n "$TS_VERSION" ]; then
    log "获取到 Tailscale 精简版最新版本: ${TS_VERSION}"
    log "当前设备架构: ${ARCH}"

    TS_URL="https://github.com/admonstrator/glinet-tailscale-updater/releases/download/${TS_VERSION}/tailscaled-linux-${ARCH}"
    log "目标下载地址: ${TS_URL}"

    cat > "$TS_MAKEFILE" << EOF
include \$(TOPDIR)/rules.mk

PKG_NAME:=tailscale
PKG_VERSION:=${TS_VERSION#v}
PKG_RELEASE:=1

include \$(INCLUDE_DIR)/package.mk

define Package/tailscale
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Zero config VPN (Pre-compiled)
  URL:=https://tailscale.com
  DEPENDS:=+ca-bundle +kmod-tun
  PROVIDES:=tailscaled
endef

define Package/tailscale/description
  Tailscale is a zero config virtual private network. (Custom Pre-compiled minimal version)
endef

define Package/tailscale/conffiles
/etc/config/tailscale
/etc/tailscale/
endef

define Build/Prepare
	mkdir -p \$(PKG_BUILD_DIR)
endef

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

    log "Tailscale Makefile 重写完成 ✔"
  else
    log "❌ 错误: 未能获取到 Tailscale 最新版本号，请检查网络或 GitHub API 速率限制"
  fi
else
  log "❌ 错误: 未找到 Tailscale Makefile ($TS_MAKEFILE)，请检查 feeds 是否已正确更新"
fi

cd "$PKG_PATCH" || exit 1

if [ -d "./luci-theme-argon" ]; then
  section "替换 Argon 背景与样式"
  cp -f $GITHUB_WORKSPACE/images/bg1.jpg luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
  
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

# 保持脚本执行完毕后路径整洁
cd "$PKG_PATCH" || exit 1

section "脚本处理完成"
log "所有数据和配置处理已完成 ✔"
exit 0