#!/bin/bash

# 移除要替换的包
find ../ | grep Makefile | grep v2ray-geodata | xargs rm -f
find ../ | grep Makefile | grep mosdns | xargs rm -f

find ../feeds/luci/ -name '*ssr-plus*' | xargs rm -rf
find ../feeds/luci/ -name '*passwall*' | xargs rm -rf
find ../feeds/luci/ -name '*mihomo*' | xargs rm -rf
find ../feeds/luci/ -name '*openclash*' | xargs rm -rf
find ../feeds/luci/ -name '*homeproxy*' | xargs rm -rf

find ../feeds/luci/ -name '*lucky*' | xargs rm -rf
find ../feeds/luci/ -name '*adguardhome*' | xargs rm -rf
find ../feeds/luci/ -name '*argon*' | xargs rm -rf
find ../feeds/luci/ -name '*design*' | xargs rm -rf

rm -rf ../feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x ../feeds/packages/lang/golang

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../
  cd .. && rm -rf $repodir
}

git_sparse_clone dev https://github.com/vernesong/OpenClash luci-app-openclash

git clone --depth=1 -b main https://github.com/xiaorouji/openwrt-passwall.git openwrt-passwall
git clone --depth=1 -b main https://github.com/xiaorouji/openwrt-passwall-packages.git openwrt-passwall-packages

git clone --depth=1 -b v5 https://github.com/sbwml/luci-app-mosdns.git luci-app-mosdns
git clone --depth=1 -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata
git clone --depth=1 -b main https://github.com/gdy666/luci-app-lucky.git luci-app-lucky
git clone --depth=1 -b master https://github.com/acnixuil/luci-app-adguardhome.git luci-app-adguardhome

# 判断 REPO_URL 是否包含 'lede' 或 'ipq6000'，设置分支并运行相应的 git clone 命令
if [[ "$REPO_URL" == *"lede"* || "$REPO_URL" == *"ipq6000"* ]]; then
  git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon
  git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config
  git clone --depth=1 -b main https://github.com/ophub/luci-app-amlogic.git luci-app-amlogic
else
  git clone --depth=1 -b master https://github.com/jerrykuku/luci-theme-argon.git luci-theme-argon
  git clone --depth=1 -b master https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config
  git clone --depth=1 -b main https://github.com/morytyann/OpenWrt-mihomo.git mihomo
  git clone --depth=1 -b main https://github.com/VIKINGYFY/homeproxy.git homeproxy
fi

echo "========================="
echo " 插件列表已更新"
