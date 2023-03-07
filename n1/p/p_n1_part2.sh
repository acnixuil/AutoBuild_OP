#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

# firewall custom
#echo "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> package/network/config/firewall/files/firewall.user
echo "iptables -t nat -I POSTROUTING -j FULLCONENAT" >> package/network/config/firewall/files/firewall.user

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.254/g' package/base-files/files/bin/config_generate

# 配置alist3编译环境
#rm -rf feeds/packages/lang/golang
#svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang

# 添加alist
#git clone https://github.com/sbwml/luci-app-alist package/alist

# 添加adguardhome
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome

# 更换design为最新版本
#rm -rf feeds/luci/themes/luci-theme-design
#git clone https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
#git clone https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config

# 更换argon为最新版本
#git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
#rm -rf feeds/luci/themes/luci-theme-argon
#git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# 添加晶晨宝盒
#svn co https://github.com/ophub/luci-app-amlogic/trunk/luci-app-amlogic package/luci-app-amlogic