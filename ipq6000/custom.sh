#!/bin/bash

# 默认ip
sed -i -E 's/192\.168\.[0-9]{1,3}\.1/192.168.'"${SUBNET}"'.1/g' base-files/files/bin/config_generate
echo "检查 config_generate 中 lan 默认 IP 是否修改："
grep -oP 'lan\)\s+ipad=\${ipaddr:-"\K192\.168\.[0-9]{1,3}\.1(?=")' base-files/files/bin/config_generate

# 主机名
sed -i "s/\(set system.@system\[-1\].hostname=\).*/\1'OpenWrt'/" base-files/files/bin/config_generate
echo "检查 config_generate 中默认主机名："
grep -oP "set system.@system\[-1\].hostname='\K[^']+" base-files/files/bin/config_generate

# 修改ssid
sed -i "s/ssid='.*'/ssid='99Pass1'/g" network/config/wifi-scripts/files/lib/wifi/mac80211.uc
# sed -i "s/disabled='.*'/disabled='1'/g" network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s/key='.*'/key='qwer1234'/g" network/config/wifi-scripts/files/lib/wifi/mac80211.uc

# 设置ttyd免帐号登录
sed -i 's/\/bin\/login/\/bin\/login -f root/' ../feeds/packages/utils/ttyd/files/ttyd.config
sed -i "/option interface/d" ../feeds/packages/utils/ttyd/files/ttyd.config

# 显示增加编译时间
if [ "${REPO_BRANCH#*-}" = "23.05" ]; then
   sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"OpenWrt R$(TZ=UTC-8 date +'%y.%-m.%-d') (By @COLDFISH build $(TZ=UTC-8 date '+%Y-%m-%d %H:%M'))\"/g" base-files/files/etc/openwrt_release
   echo -e "\e[96m当前写入的编译时间: $(grep 'DISTRIB_DESCRIPTION' base-files/files/etc/openwrt_release)\e[0m"
else
   sed -i "s/DISTRIB_DESCRIPTION=.*/DISTRIB_DESCRIPTION=\"OpenWrt By @COLDFISH\"/g" base-files/files/etc/openwrt_release
   sed -i "s/OPENWRT_RELEASE=.*/OPENWRT_RELEASE=\"OpenWrt R$(TZ=UTC-8 date +'%y.%-m.%-d') (By @COLDFISH build $(TZ=UTC-8 date '+%Y-%m-%d %H:%M'))\"/g"  base-files/files/usr/lib/os-release
   echo -e "\e[92m当前写入的编译时间: $(grep 'OPENWRT_RELEASE' base-files/files/usr/lib/os-release)\e[0m"
fi

echo "定制化设置已完成"