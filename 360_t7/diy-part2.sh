#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

# Modify default IP
sed -i 's/192.168.6.1/192.168.2.1/g' package/base-files/files/bin/config_generate

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

# argon design
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
git clone --depth=1 -b main https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
git clone --depth=1 -b master https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# mosdns
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth=1 -b master https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
cp -f package/v2ray-geodata/Makefile feeds/packages/net/v2ray-geodata/Makefile

# ssrp
git clone --depth=1 -b master https://github.com/fw876/helloworld package/luci-app-ssr-plus

#Enable Cache
#echo -e 'CONFIG_DEVEL=y\nCONFIG_CCACHE=y' >> .config

