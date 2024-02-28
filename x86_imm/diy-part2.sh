#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

echo "开始 DIY2 配置……"
echo "========================="

# 修改网关ip
sed -i 's/192.168.1.1/192.168.3.1/g' package/base-files/files/bin/config_generate

# 向导
#git clone https://github.com/sirpdboy/luci-app-wizard package/luci-app-wizard
git clone https://github.com/acnixuil/luci-app-netwizard.git package/luci-app-wizard

# 添加adguardhome
#git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome
git clone --depth=1 -b master https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# 更换argon为最新版本
rm -rf feeds/luci/themes/luci-theme-argon*
rm -rf feeds/luci/applications/luci-app-argon-config*
git clone --depth=1 -b master https://github.com/yhl452493373/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# lucky 大吉
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
sed -i '/<footer class="mobile-hide">/,/<\/footer>/ s|<div>.*<\/div>| |' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm

echo "========================="
echo " DIY2 配置完成……"
