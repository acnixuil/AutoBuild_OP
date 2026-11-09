include $(TOPDIR)/rules.mk

PKG_NAME:=sing-box
PKG_VERSION:=1.0.0
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

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	echo "Downloading sing-box: __SINGBOX_URL__"
	curl -fL -k -o $(PKG_BUILD_DIR)/sing-box.tar.gz "__SINGBOX_URL__"
	mkdir -p $(PKG_BUILD_DIR)/extract
	tar -xzf $(PKG_BUILD_DIR)/sing-box.tar.gz -C $(PKG_BUILD_DIR)/extract
	rm -f $(PKG_BUILD_DIR)/sing-box.tar.gz
	find $(PKG_BUILD_DIR)/extract -type f -name "sing-box" -exec cp -f {} $(PKG_BUILD_DIR)/sing-box \;
	[ -s $(PKG_BUILD_DIR)/sing-box ] || find $(PKG_BUILD_DIR)/extract -type f -iname "*sing*box*" -exec cp -f {} $(PKG_BUILD_DIR)/sing-box \;
	head -c 4 $(PKG_BUILD_DIR)/sing-box | od -An -tx1 | cut -c2-12 | grep -q "7f 45 4c 46"
	chmod +x $(PKG_BUILD_DIR)/sing-box
endef

define Package/sing-box/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sing-box $(1)/usr/bin/sing-box
endef

$(eval $(call BuildPackage,sing-box))
