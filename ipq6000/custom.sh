#!/bin/bash

# 修改默认ip
echo "${SUBNET}"
sed -i "s/192\.168\.1\.[0-9]\{1,3\}/192.168.${SUBNET}.1/g" base-files/files/bin/config_generate

# 修改ssid
sed -i 's/LiBwrt/99Pass1/' ../target/linux/qualcommax/base-files/etc/uci-defaults/990_set-wireless.sh
sed -i "s/ssid='.*'/ssid='99Pass1'/g" network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/disabled='0'/disabled='1'/" ../target/linux/qualcommax/base-files/etc/uci-defaults/990_set-wireless.sh
sed -i "s/disabled='.*'/disabled='1'/g" network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/key='.*'/key='12345678'/g" network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/country='.*'/country='CN'/g" network/config/wifi-scripts/files/lib/wifi/mac80211.uc

# 设置ttyd免帐号登录
sed -i 's/\/bin\/login/\/bin\/login -f root/' ../feeds/packages/utils/ttyd/files/ttyd.config

# 显示增加编译时间
if [ "${REPO_BRANCH#*-}" = "23.05" ]; then
   sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"OpenWrt R$(TZ=UTC-8 date +'%y.%-m.%-d') (By @COLDFISH build $(TZ=UTC-8 date '+%Y-%m-%d %H:%M'))\"/g"  base-files/files/etc/openwrt_release
   echo -e "\e[41m当前写入的编译时间:\e[0m \e[33m$(grep 'DISTRIB_DESCRIPTION' base-files/files/etc/openwrt_release)\e[0m"
else
   sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"OpenWrt By @COLDFISH\"/g" base-files/files/etc/openwrt_release
   sed -i "s/OPENWRT_RELEASE=.*/OPENWRT_RELEASE=\"OpenWrt R$(TZ=UTC-8 date +'%y.%-m.%-d') (By @COLDFISH build $(TZ=UTC-8 date '+%Y-%m-%d %H:%M'))\"/g"  base-files/files/usr/lib/os-release
   echo -e "\e[41m当前写入的编译时间:\e[0m \e[33m$(grep 'OPENWRT_RELEASE' base-files/files/usr/lib/os-release)\e[0m"
fi

echo "定制化设置已完成"