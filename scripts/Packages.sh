#!/bin/bash

# 移除要替换的包
find ../ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ../ | grep Makefile | grep mosdns | xargs rm -f
find ../feeds/luci/ -name '*passwall*' | xargs rm -rf
find ../feeds/luci/ -name '*nikki*' | xargs rm -rf
find ../feeds/luci/ -name '*openclash*' | xargs rm -rf
find ../feeds/luci/ -name '*lucky*' | xargs rm -rf
find ../feeds/luci/ -name '*adguardhome*' | xargs rm -rf
find ../feeds/luci/ -name '*argon*' | xargs rm -rf

rm -rf $GITHUB_WORKSPACE/openwrt/feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 24.x $GITHUB_WORKSPACE/openwrt/feeds/packages/lang/golang

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../
  cd .. && rm -rf $repodir
}

# openclash
git_sparse_clone dev https://github.com/vernesong/OpenClash luci-app-openclash

# WORKINGDIR="../feeds/packages/net/smartdns"
# mkdir $WORKINGDIR -p
# rm $WORKINGDIR/* -fr
# wget https://github.com/pymumu/openwrt-smartdns/archive/master.zip -O $WORKINGDIR/master.zip
# unzip $WORKINGDIR/master.zip -d $WORKINGDIR
# mv $WORKINGDIR/openwrt-smartdns-master/* $WORKINGDIR/
# rmdir $WORKINGDIR/openwrt-smartdns-master
# rm $WORKINGDIR/master.zip
#
# LUCIBRANCH="master" #更换此变量
# WORKINGDIR="../feeds/luci/applications/luci-app-smartdns"
# mkdir $WORKINGDIR -p
# rm $WORKINGDIR/* -fr
# wget https://github.com/pymumu/luci-app-smartdns/archive/${LUCIBRANCH}.zip -O $WORKINGDIR/${LUCIBRANCH}.zip
# unzip $WORKINGDIR/${LUCIBRANCH}.zip -d $WORKINGDIR
# mv $WORKINGDIR/luci-app-smartdns-${LUCIBRANCH}/* $WORKINGDIR/
# rmdir $WORKINGDIR/luci-app-smartdns-${LUCIBRANCH}
# rm $WORKINGDIR/${LUCIBRANCH}.zip

git clone --depth=1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall.git openwrt-passwall
git clone --depth=1 --single-branch -b main https://github.com/xiaorouji/openwrt-passwall-packages.git openwrt-passwall-packages

# mosdns
git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns.git luci-app-mosdns
git clone --depth=1 --single-branch -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata

# adguardhome
git clone --depth=1 --single-branch -b master https://github.com/acnixuil/luci-app-adguardhome.git luci-app-adguardhome

# tailscale
git clone --depth=1 --single-branch -b main https://github.com/asvow/luci-app-tailscale luci-app-tailscale

# smartdns
find ../feeds -type d -name '*smartdns*' -prune -exec rm -rf {} +
git clone --depth=1 --single-branch -b master https://github.com/pymumu/luci-app-smartdns ../feeds/luci/applications/luci-app-smartdns
git clone --depth=1 --single-branch -b master https://github.com/pymumu/openwrt-smartdns ../feeds/packages/net/smartdns

# lucky
git clone --depth=1 --single-branch -b main https://github.com/sirpdboy/luci-app-lucky.git

# 主题
git clone --depth=1 --single-branch -b master https://github.com/yhl452493373/luci-theme-argon luci-theme-argon
git clone --depth=1 --single-branch -b master https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config

git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-nikki.git nikki

../scripts/feeds install -a

echo "========================="
echo " 插件列表已更新"
