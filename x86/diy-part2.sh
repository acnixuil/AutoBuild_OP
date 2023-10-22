#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

echo "开始 DIY2 配置……"
echo "========================="

# 修改内核版本
#sed -i '/.*KERNEL_PATCHVER*/c\KERNEL_PATCHVER:=5.15' target/linux/x86/Makefile

# 修改网关ip
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# 取消登录密码
sed -i '/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF./d' package/lean/default-settings/files/zzz-default-settings

# 调整 x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}/g' package/lean/autocore/files/x86/autocore

# 添加adguardhome
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome
#svn co https://github.com/kenzok8/openwrt-packages/trunk/luci-app-adguardhome package/luci-app-adguardhome

# argon design
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
#git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
#git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-mosdns
svn co https://github.com/sbwml/luci-app-mosdns/trunk/luci-app-mosdns package/luci-app-mosdns
svn co https://github.com/sbwml/luci-app-mosdns/trunk/mosdns package/mosdns

# 向导
git clone https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard

# Enable Cache
echo -e 'CONFIG_DEVEL=y\nCONFIG_CCACHE=y' >> .config

./scripts/feeds update -a
./scripts/feeds install -a

echo "========================="
echo " DIY2 配置完成……"