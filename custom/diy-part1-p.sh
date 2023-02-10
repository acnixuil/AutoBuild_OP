# sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# passwall
sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall.git;packages' feeds.conf.default
sed -i '$a src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci' feeds.conf.default

# 添加adguardhome
git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome

# 更换argon为最新版本
git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
rm -rf feeds/luci/themes/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# 添加alist
rm -rf feeds/packages/lang/golang
svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang
git clone https://github.com/sbwml/luci-app-alist package/alist


