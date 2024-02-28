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

# mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 添加adguardhome
#git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome
git clone --depth=1 -b master https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# 向导
#git clone https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard
git clone --depth=1 -b main https://github.com/acnixuil/luci-app-netwizard.git package/luci-app-wizard

# argon design
rm -rf feeds/luci/themes/luci-theme-argon*
rm -rf feeds/luci/themes/luci-theme-design*
rm -rf feeds/luci/applications/luci-app-argon-config*
rm -rf feeds/luci/applications/luci-app-design-config*
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config
git clone --depth=1 -b main https://github.com/gngpp/luci-theme-design.git package/luci-theme-design
git clone --depth=1 -b master https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i '/<footer class="mobile-hide">/,/<\/footer>/ s|<div>.*<\/div>| |' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm

# lucky 大吉
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# msd_lite
rm -rf feeds/packages/net/msd_lite
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

echo "========================="
echo " DIY2 配置完成……"