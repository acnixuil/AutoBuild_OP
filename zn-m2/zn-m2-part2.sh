#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 配置alist3编译环境
#rm -rf feeds/packages/lang/golang
#svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang

# 添加alist
#git clone https://github.com/sbwml/luci-app-alist package/alist

# 添加adguardhome
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome

# 更换design为最新版本
rm -rf feeds/luci/themes/luci-theme-design
git clone https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
git clone https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config

# 更换argon为最新版本
#git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
#rm -rf feeds/luci/themes/luci-theme-argon
#git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# passwall
rm -rf feeds/luci/applications/luci-app-passwall
git clone https://github.com/xiaorouji/openwrt-passwall.git -b packages ./package/passwall_package
git clone https://github.com/xiaorouji/openwrt-passwall.git -b luci ./package/passwall