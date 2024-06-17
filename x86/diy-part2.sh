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

# Git稀疏克隆，只克隆指定目录到本地
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
# neko
git_sparse_clone luci-app-neko https://github.com/nosignals/neko luci-app-neko

# helloworld
#rm -rf feeds/packages/net/{xray-core,v2ray-core,v2ray-geodata,sing-box}
#git clone https://github.com/sbwml/openwrt_helloworld package/helloworld

# mosdns
find ./ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ./ | grep Makefile | grep mosdns | xargs rm -f
sed -i '/^GO_PKG_TARGET_VARS:=$(filter-out CGO_ENABLED=%,$(GO_PKG_TARGET_VARS)) CGO_ENABLED=0$/d' feeds/packages/utils/v2dat/Makefile
git clone https://github.com/sbwml/luci-app-mosdns -b v5 package/mosdns
git clone https://github.com/sbwml/v2ray-geodata package/v2ray-geodata

# 添加adguardhome
#git clone https://github.com/kongfl888/luci-app-adguardhome.git package/luci-app-adguardhome
git clone --depth=1 -b master https://github.com/acnixuil/luci-app-adguardhome.git package/luci-app-adguardhome

# lucky 大吉
git clone https://github.com/gdy666/luci-app-lucky.git package/lucky

# msd_lite
rm -rf feeds/packages/net/msd_lite
git clone --depth=1 https://github.com/ximiTech/luci-app-msd_lite package/luci-app-msd_lite
git clone --depth=1 https://github.com/ximiTech/msd_lite package/msd_lite

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

echo "========================="
echo " DIY2 配置完成……"