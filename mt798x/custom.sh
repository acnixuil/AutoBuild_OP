#!/bin/bash

# 修改默认ip
echo "${SUBNET}"
sed -i "s/192\.168\.1\.[0-9]\{1,3\}/192.168.${SUBNET}.1/g" base-files/files/bin/config_generate

# 修改ssid
sed -i "/htbsscoex=\"1\"/{n; s/ssid=\".*\"/ssid=\"万事大吉daji_2.4G\"/}" mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "/htbsscoex=\"0\"/{n; s/ssid=\".*\"/ssid=\"万事大吉daji\"/}" mtk/applications/mtwifi-cfg/files/mtwifi.sh

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