#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

# firewall custom
echo "iptables -t nat -I POSTROUTING -j FULLCONENAT" >> package/network/config/firewall/files/firewall.user

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.254/g' package/base-files/files/bin/config_generate

# alist3
#rm -rf feeds/packages/lang/golang
#svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang
#git clone https://github.com/sbwml/luci-app-alist package/alist

# adguardhome
git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome

# argon design
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-design
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-design-config
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
git clone https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
git clone https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-confign

# 添加晶晨宝盒
svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic
sed -i "s|ARMv8|ARMv8|g" package/luci-app-amlogic/root/etc/config/amlogic

# mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
svn co https://github.com/sbwml/luci-app-mosdns/trunk/luci-app-mosdns package/luci-app-mosdns
svn co https://github.com/sbwml/luci-app-mosdns/trunk/mosdns package/mosdns

# 向导
git clone https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard

# turboacc 去dns
# sed -i '60,70d' feeds/luci/applications/luci-app-turboacc/Makefile
# sed -i '54,78d' feeds/luci/applications/luci-app-turboacc/luasrc/model/cbi/turboacc.lua
# sed -i '7d;15d;21d' feeds/luci/applications/luci-app-turboacc/luasrc/view/turboacc/turboacc_status.htm
rm -rf feeds/luci/applications/luci-app-turboacc
svn co https://github.com/xiangfeidexiaohuo/openwrt-packages/trunk/patch/luci-app-turboacc package/luci-app-turboacc

./scripts/feeds update -a
./scripts/feeds install -a -f
