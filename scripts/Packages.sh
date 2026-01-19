#!/bin/bash

# 移除要替换的包
find ../ -name '*v2ray-geodata*' -exec rm -rf {} +
find ../ -name '*mosdns*' -exec rm -rf {} +
find ../feeds/luci/ -name '*passwall*' | xargs rm -rf
find ../feeds/luci/ -name '*nikki*' | xargs rm -rf
find ../feeds/luci/ -name '*openclash*' | xargs rm -rf
find ../feeds/luci/ -name '*lucky*' | xargs rm -rf
find ../feeds/luci/ -name '*adguardhome*' | xargs rm -rf
find ../feeds/luci/ -name '*argon*' | xargs rm -rf
find ../feeds/luci/ -name '*luci-app-tailscale-community*' | xargs rm -rf

rm -rf ../feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 25.x ../feeds/packages/lang/golang

# Git稀疏克隆，只克隆指定目录到本地
# git_sparse_clone 分支名 仓库地址 需要下载的目录
git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  tmpdir="$(basename -s .git "$repourl")_tmp"
  git clone --depth=1 -b "$branch" --single-branch --filter=blob:none --sparse "$repourl" "$tmpdir"
  cd "$tmpdir" || exit 1
  git sparse-checkout set "$@"
  mv -f "$@" ../
  cd .. && rm -rf "$tmpdir"
}

# openclash
git_sparse_clone dev https://github.com/vernesong/OpenClash luci-app-openclash
git_sparse_clone master https://github.com/Tokisaki-Galaxy/luci-app-tailscale-community.git luci-app-tailscale-community

# git clone --depth=1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall.git openwrt-passwall
# git clone --depth=1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall-packages.git openwrt-passwall-packages

# mosdns
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns.git luci-app-mosdns
git clone --depth=1 --single-branch -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata

# adguardhome
git clone --depth=1 --single-branch -b master https://github.com/acnixuil/luci-app-adguardhome.git luci-app-adguardhome

# smartdns
# find ../ -name '*smartdns*' -exec rm -rf {} +
# git clone --depth=1 --single-branch -b master https://github.com/pymumu/luci-app-smartdns ../feeds/luci/applications/luci-app-smartdns
# git clone --depth=1 --single-branch -b master https://github.com/pymumu/openwrt-smartdns ../feeds/packages/net/smartdns

# lucky
git clone --depth=1 --single-branch -b main https://github.com/sirpdboy/luci-app-lucky.git

# 主题
git clone --depth=1 --single-branch -b master https://github.com/yhl452493373/luci-theme-argon luci-theme-argon
git clone --depth=1 --single-branch -b master https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config

git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-nikki.git nikki
git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-momo.git momo

echo "正在配置自定义 Sing-box..."
echo "当前设定架构 (CLASH_KERNEL): $CLASH_KERNEL"

rm -rf ../feeds/packages/net/sing-box
mkdir -p ../package/sing-box

# 3.3 写入自定义 Makefile (分两段写入，中间插入变量)

# --- 第一部分：头部定义 ---
cat > ../package/sing-box/Makefile << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=custom
PKG_RELEASE:=$(shell date +%Y%m%d)

include $(INCLUDE_DIR)/package.mk

define Package/sing-box
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Sing-box (Custom Binary from CF Pages)
  DEPENDS:=+ca-bundle +kmod-tun
endef

define Package/sing-box/description
  Downloads pre-compiled sing-box binary from Cloudflare Pages.
endef

# 直接使用环境变量定义架构
EOF

# --- 中间部分：注入 CLASH_KERNEL 变量 ---
# 这里直接把脚本运行时的环境变量值写入 Makefile
echo "DOWNLOAD_ARCH:=${CLASH_KERNEL}" >> ../package/sing-box/Makefile

# --- 第三部分：构建逻辑 ---
cat >> ../package/sing-box/Makefile << 'EOF'

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	# 直接引用上面定义的 DOWNLOAD_ARCH 变量
	echo "Downloading sing-box for $(DOWNLOAD_ARCH)..."
	curl -L -k -o $(PKG_BUILD_DIR)/sing-box.tar.gz "https://singbox-custom-dl.pages.dev/sing-box-$(DOWNLOAD_ARCH).tar.gz"
	
	# 解压
	tar -xzvf $(PKG_BUILD_DIR)/sing-box.tar.gz -C $(PKG_BUILD_DIR)
endef

define Package/sing-box/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sing-box $(1)/usr/bin/sing-box
endef

$(eval $(call BuildPackage,sing-box))
EOF

echo "========================="
echo " 插件列表与自定义 sing-box ($CLASH_KERNEL) 已配置完成"

# ../scripts/feeds install -a

echo "========================="
echo " 插件列表已更新"
