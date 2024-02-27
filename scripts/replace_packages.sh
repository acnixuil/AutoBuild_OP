# 运行在 install feeds 之前
# Tailscale
pushd feeds/packages/net
rm -rf tailscale
git clone --depth 1 --branch master https://github.com/openwrt/packages.git tailscale_new
cp -r tailscale_new/net/tailscale .
rm -rf tailscale_new
sed -i 's/option fw_mode nftables/option fw_mode iptables/' tailscale/files/tailscale.conf
sed -i 's/fw_mode nftables/fw_mode iptables/' tailscale/files/tailscale.init
popd

# Zerotier
pushd feeds/packages/net
rm -rf zerotier
git clone --depth 1 --branch master https://github.com/immortalwrt/packages.git zerotier_new
cp -r zerotier_new/net/zerotier .
rm -rf zerotier_new
popd

UPDATE_VERSION() {
	local PKG_NAME=$1
	local NEW_VER=$2
	local NEW_HASH=$3
	local PKG_FILE=$(find ../feeds/packages/*/$PKG_NAME/ -type f -name "Makefile" 2>/dev/null)

	if [ -f "$PKG_FILE" ]; then
		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" $PKG_FILE)
		if dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" $PKG_FILE
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" $PKG_FILE
			echo "$PKG_NAME ver has updated!"
		else
			echo "$PKG_NAME ver is latest!"
		fi
	else
		echo "$PKG_NAME not found!"
	fi
}

UPDATE_VERSION "sing-box" "1.8.5" "0d5e6a7198c3a18491ac35807170715118df2c7b77fd02d16d7cfb5791e368ce"