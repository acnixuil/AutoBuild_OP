#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

echo "开始 DIY2 配置……"
echo "========================="

# 修改网关ip
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# 添加adguardhome
#git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome
git clone https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# 向导
#git clone https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard
git clone https://github.com/acnixuil/luci-app-netwizard.git package/luci-app-wizard

# 更换design为最新版本
#rm -rf feeds/luci/themes/luci-theme-design
#git clone https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
#git clone https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config

# 更换argon为最新版本
rm -rf feeds/luci/themes/luci-theme-argon*
git clone https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
git clone https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon

# mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# Enable Cache
#echo -e 'CONFIG_DEVEL=y\nCONFIG_CCACHE=y' >> .config

echo "========================="
echo " DIY2 配置完成……"
