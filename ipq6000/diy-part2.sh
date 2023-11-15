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
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# adguardhome
git clone --depth=1 https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# argon design
rm -rf feeds/luci/themes/luci-theme-argon*
rm -rf feeds/luci/themes/luci-theme-design*
rm -rf feeds/luci/applications/luci-app-argon-config*
rm -rf feeds/luci/applications/luci-app-design-config*
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
git clone https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
git clone https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config

find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

git clone -b main https://github.com/fw876/helloworld package/luci-app-ssr-plus

# Enable Cache
#echo -e 'CONFIG_DEVEL=y\nCONFIG_CCACHE=y' >> .config

echo "========================="
echo " DIY2 配置完成……"
