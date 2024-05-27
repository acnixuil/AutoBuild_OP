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
#rm -rf feeds/luci/applications/luci-app-ssr-plus
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-openclash

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash
# git clone --depth=1 -b main https://github.com/fw876/helloworld package/luci-app-ssr-plus

function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}
# openclash
git_sparse_clone master https://github.com/vernesong/OpenClash luci-app-openclash

# 移除 openwrt feeds 自带的核心包
rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box,chinadns-ng}
git clone https://github.com/sbwml/openwrt_helloworld package/helloworld

# 更新 golang 1.22 版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

# adguardhome
git clone --depth=1 -b master https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# mosdns
git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns package/mosdns
git clone --depth=1 -b master https://github.com/sbwml/v2ray-geodata package/v2ray-geodata
cp -f package/v2ray-geodata/Makefile feeds/packages/net/v2ray-geodata/Makefile

# ## -------------- lucky ---------------------------
# rm -rf feeds/packages/net/lucky
rm -rf feeds/luci/applications/luci-app-lucky
git clone https://github.com/gdy666/luci-app-lucky.git package/custom/lucky
# git clone https://github.com/sirpdboy/luci-app-lucky.git package/custom/lucky
sleep 1
## customize lucky ver
# wget https://www.daji.it:6/files/$(PKG_VERSION)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz
lkver=2.5.3
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$lkver"'/g;s/github.com\/gdy666\/lucky\/releases\/download\/v/www.daji.it\:6\/files\//g' package/custom/lucky/lucky/Makefile
# wget https://github.com/gdy666/lucky-files$(PKG_VERSION)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz
# lkver=2.5.1
# sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$lkver"'/g;s/lucky\/releases\/download\/v/lucky-files\/raw\/main\//g' package/custom/lucky/lucky/Makefile
# cat package/custom/lucky/lucky/Makefile
# ## ---------------------------------------------------------

# argon
#git clone --depth=1 -b master https://github.com/yhl452493373/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon.git package/luci-theme-argon
git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config.git package/luci-app-argon-config

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
perl -0777 -i -pe 's|<footer class="mobile-hide">\s*<div>.*?</div>\s*</footer>|<footer class="mobile-hide">\n\t<div>\n\t</div>\n</footer>|s' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
perl -0777 -i -pe 's|<footer>\s*<div>.*?</div>\s*</footer>|<footer>>\n\t<div>\n\t</div>\n</footer>|s' package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

#修改默认WIFI名
WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
sed -i "/htbsscoex=\"1\"/{n; s/ssid=\".*\"/ssid=\"大吉99_2.4G\"/}" $WIFI_FILE
sed -i "/htbsscoex=\"0\"/{n; s/ssid=\".*\"/ssid=\"大吉99\"/}" $WIFI_FILE