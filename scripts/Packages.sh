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
git_sparse_clone main https://github.com/stackia/rtp2httpd.git openwrt-support

RT_MAKEFILE="openwrt-support/rtp2httpd/Makefile"

# 路径兼容性判断
if [ ! -f "$RT_MAKEFILE" ]; then
    RT_MAKEFILE="package/openwrt-support/rtp2httpd/Makefile"
fi

if [ -f "$RT_MAKEFILE" ]; then
    echo "正在重写 $RT_MAKEFILE ..."

    # 注意：下面的 EOF 必须带单引号
    cat > "$RT_MAKEFILE" << 'EOF'
include $(TOPDIR)/rules.mk

PKG_NAME:=rtp2httpd
RELEASE_VERSION:=$(if $(DUMP),unknown,$(shell \
	cd $(CURDIR)/../.. 2>/dev/null && \
	if git describe --tags --exact-match --match 'v*' 2>/dev/null >/dev/null && \
	   git diff --quiet 2>/dev/null && \
	   git diff --cached --quiet 2>/dev/null; then \
		git describe --tags --exact-match --match 'v*' 2>/dev/null | sed 's/^v//'; \
	else \
		echo "$$(date +%Y%m%d)"; \
	fi))

PKG_VERSION:=$(shell echo "$(RELEASE_VERSION)" | sed 's/-\([a-z]*\)\.\([0-9]*\)/_\1\2/g')
PKG_RELEASE:=1
PKG_MAINTAINER:=Stackie Jia <jsq2627@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

export RELEASE_VERSION

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) $(CURDIR)/../../* $(PKG_BUILD_DIR)/
endef

define Package/rtp2httpd
	SECTION:=net
	CATEGORY:=Network
	TITLE:=Convert RTP/UDP/RTSP streams into HTTP streams
	URL:=https://github.com/stackia/rtp2httpd
endef

define Package/rtp2httpd/description
	rtp2httpd converts RTP/UDP/RTSP media into http stream.
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/src/rtp2httpd \
		$(PKG_BUILD_DIR)/src/*.c
endef

define Package/rtp2httpd/conffiles
/etc/config/rtp2httpd
/etc/rtp2httpd.conf
endef

define Package/rtp2httpd/install
	$(INSTALL_DIR) $(1)/etc/init.d $(1)/etc/config $(1)/usr/bin
	$(INSTALL_CONF) ./files/rtp2httpd.conf $(1)/etc/config/rtp2httpd
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/rtp2httpd.conf $(1)/etc
	$(INSTALL_BIN) ./files/rtp2httpd.init $(1)/etc/init.d/rtp2httpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/rtp2httpd $(1)/usr/bin
endef

$(eval $(call BuildPackage,rtp2httpd))
EOF

    # 【重要】强制将 Makefile 中的每行开头的连续空格转换为 Tab，防止复制粘贴导致的缩进错误
    sed -i 's/^[[:space:]]\+/\t/' "$RT_MAKEFILE"
    
    echo "$RT_MAKEFILE 重写完成。"
else
    echo "错误：找不到文件 $RT_MAKEFILE，跳过重写。"
fi

git clone --depth=1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall.git openwrt-passwall
git clone --depth=1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall-packages.git openwrt-passwall-packages

# mosdns
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns.git luci-app-mosdns
git clone --depth=1 --single-branch -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata

# adguardhome
git clone --depth=1 --single-branch -b master https://github.com/acnixuil/luci-app-adguardhome.git luci-app-adguardhome

# tailscale
# git clone --depth=1 --single-branch -b main https://github.com/Tokisaki-Galaxy/luci-app-tailscale-community.git

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

# ../scripts/feeds install -a

echo "========================="
echo " 插件列表已更新"
