# 运行在 install feeds 之前
# Tailscale
#pushd feeds/packages/net
#rm -rf tailscale
#git clone --depth 1 --branch master https://github.com/openwrt/packages.git tailscale_new
#cp -r tailscale_new/net/tailscale .
#rm -rf tailscale_new
#sed -i 's/option fw_mode nftables/option fw_mode iptables/' tailscale/files/tailscale.conf
#sed -i 's/fw_mode nftables/fw_mode iptables/' tailscale/files/tailscale.init
#popd

# Zerotier
pushd feeds/packages/net
rm -rf zerotier
git clone --depth 1 --branch master https://github.com/immortalwrt/packages.git zerotier_new
cp -r zerotier_new/net/zerotier .
rm -rf zerotier_new
popd