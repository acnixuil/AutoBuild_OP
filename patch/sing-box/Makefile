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