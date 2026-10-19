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
	echo "Downloading pre-compiled tailscale from __URL__"
	curl -L -k -o $(PKG_BUILD_DIR)/tailscaled "__URL__"
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