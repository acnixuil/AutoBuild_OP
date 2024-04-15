#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)

# Modify default IP
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# 移除要替换的包
#find ./ -name '*mosdns*' -print0 | xargs -0 rm -rf
#rm -f package/feeds/packages/mosdns
#rm -rf feeds/packages/net/mosdns
#rm -rf feeds/packages/net/v2ray-geodata*
rm -rf feeds/luci/themes/luci-theme-argon*
rm -rf feeds/luci/themes/luci-theme-design*
rm -rf feeds/luci/applications/luci-app-argon-config*
rm -rf feeds/luci/applications/luci-app-design-config*
rm -rf feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/luci/applications/luci-app-passwall

rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang
git clone --depth=1 -b main https://github.com/fw876/helloworld package/luci-app-ssr-plus

# lucky 大吉
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# adguardhome
git clone --depth=1 -b master https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# argon design
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
git clone --depth=1 -b main https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
git clone --depth=1 -b master https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config
sed -i -r "s#navbar_proxy = 'openclash'#navbar_proxy = 'passwall'#g" feeds/luci/themes/luci-theme-design/luasrc/view/themes/design/header.htm

# mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth=1 -b master https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# msd_lite
#rm -rf feeds/packages/net/msd_lite
#git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
#git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

# 取消主题默认设置
find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

echo "========================="
echo " DIY2 配置完成……"
