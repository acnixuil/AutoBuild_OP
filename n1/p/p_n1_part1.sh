# Add helloworld
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# Add passwall
#sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall.git;packages' feeds.conf.default
#sed -i '$a src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci' feeds.conf.default

# 第三方源
sed -i '$a src-git kenzo https://github.com/kenzok8/openwrt-packages' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small' feeds.conf.default