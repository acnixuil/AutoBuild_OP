# Add a feed source
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# 添加passwall
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> "feeds.conf.default"
