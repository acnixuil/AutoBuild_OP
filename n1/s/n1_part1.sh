# Add helloworld
sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# Add passwall
#sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall.git;packages' feeds.conf.default
#sed -i '$a src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci' feeds.conf.default