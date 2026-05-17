#!/bin/bash

# 处理主机名
TARGET_HOSTNAME="OpenWrt"
sed -i "s/\(set system.@system\[-1\].hostname=\).*/\1'${TARGET_HOSTNAME}'/" base-files/files/bin/config_generate
DETECTED_HOSTNAME=$(grep -oP "set system.@system\[-1\].hostname='\K[^']+" base-files/files/bin/config_generate | head -n 1)
echo " 💻 当前编译固件的主机名检测结果: $DETECTED_HOSTNAME "

# 修改ssid
sed -i "/htbsscoex=\"1\"/{n; s/ssid=\".*\"/ssid=\"FERN-2.4\"/}" mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "/htbsscoex=\"0\"/{n; s/ssid=\".*\"/ssid=\"FERN\"/}" mtk/applications/mtwifi-cfg/files/mtwifi.sh

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