include $(TOPDIR)/rules.mk

PKG_NAME:=tailscale
PKG_VERSION:=__VERSION__
PKG_RELEASE:=1

include $(INCLUDE_DIR)/package.mk

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
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
	echo "Downloading tiny tailscale from __URL__"
	curl -fL -k -o $(PKG_BUILD_DIR)/tailscaled "__URL__"
	head -c 4 $(PKG_BUILD_DIR)/tailscaled | od -An -tx1 | grep -q "7f 45 4c 46" || { echo "下载到的不是 ELF 二进制：__URL__"; rm -f $(PKG_BUILD_DIR)/tailscaled; exit 1; }
	chmod +x $(PKG_BUILD_DIR)/tailscaled
endef

define Package/tailscale/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tailscaled $(1)/usr/sbin/tailscaled
	$(LN) tailscaled $(1)/usr/sbin/tailscale
	$(INSTALL_BIN) ./files/tailscale.init $(1)/etc/init.d/tailscale
	$(INSTALL_DATA) ./files/tailscale.conf $(1)/etc/config/tailscale
endef

$(eval $(call BuildPackage,tailscale))