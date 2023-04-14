#sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall.git;packages' feeds.conf.default
#sed -i '$a src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci' feeds.conf.default
#
#./scripts/feeds install -a -f -p passwall_packages
#./scripts/feeds install -a -f -p passwall_luci