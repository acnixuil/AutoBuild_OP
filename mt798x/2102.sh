#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 移除要替换的包
#find ./ -name '*mosdns*' -print0 | xargs -0 rm -rf
rm -f package/feeds/packages/mosdns
rm -rf feeds/packages/net/mosdns
rm -rf feeds/packages/net/v2ray-geodata*
rm -rf feeds/luci/themes/luci-theme-argon*
rm -rf feeds/luci/themes/luci-theme-design*
rm -rf feeds/luci/applications/luci-app-argon-config*
rm -rf feeds/luci/applications/luci-app-design-config*
rm -rf feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/luci/applications/luci-app-passwall

# adguardhome
git clone --depth=1 -b master https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# mosdns
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth=1 -b master https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
cp -f package/v2ray-geodata/Makefile feeds/packages/net/v2ray-geodata/Makefile

# lucky 大吉
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# argon
git clone --depth=1 -b master https://github.com/yhl452493373/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

#修改默认WIFI名
WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
sed -i "/htbsscoex=\"1\"/{n; s/ssid=\".*\"/ssid=\"罗技鼠标接收器_2.4G\"/}" $WIFI_FILE
sed -i "/htbsscoex=\"0\"/{n; s/ssid=\".*\"/ssid=\"罗技鼠标接收器\"/}" $WIFI_FILE