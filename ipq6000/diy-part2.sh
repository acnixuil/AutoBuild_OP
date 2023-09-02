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

# 修改网关ip
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# 添加adguardhome
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome
#svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-adguardhome package/luci-app-adguardhome

# argon design主题
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-design
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-design-config
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
git clone https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
git clone https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config

# mosdns
#rm -rf feeds/packages/net/mosdns*
#rm -rf feeds/luci/applications/luci-app-mosdns*
#rm -rf feeds/packages/net/v2ray-geodata*
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
#git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 向导
git clone https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard

./scripts/feeds update -a
./scripts/feeds install -a -f

echo "========================="
echo " DIY2 配置完成……"