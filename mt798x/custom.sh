#!/bin/bash

SUBNET=${SUBNET:-2}
TARGET_IP="192.168.${SUBNET}.1"
TARGET_HOSTNAME="OpenWrt"

if [[ "$CONFIG_FILE" == *"ruijie"* ]]; then
  # 处理锐捷机型
  sed -i '/ruijie,rg-x60\*/,/;;/ s/192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'"${TARGET_IP}"'/' base-files/files/bin/config_generate
  DETECTED_IP=$(awk '/ruijie,rg-x60\*/,/;;/' base-files/files/bin/config_generate | grep -oP '192\.168\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
else
  # 处理非锐捷通用机型（修复了此处 sed 的正则匹配问题）
  sed -i '/case "\$board" in/,/esac/ {
    /^[[:space:]]*\*)/,/;;/ s/192\.168\.[0-9]\{1,3\}\.[0-9]\{1,3\}/'"${TARGET_IP}"'/
  }' base-files/files/bin/config_generate
  DETECTED_IP=$(awk '/case "\$board" in/,/esac/' base-files/files/bin/config_generate | awk '/^[[:space:]]*\*\)/,/;;/' | grep -oP '192\.168\.[0-9]{1,3}\.[0-9]{1,3}' | head -n 1)
fi

# 处理主机名
sed -i "s/\(set system.@system\[-1\].hostname=\).*/\1'${TARGET_HOSTNAME}'/" base-files/files/bin/config_generate
DETECTED_HOSTNAME=$(grep -oP "set system.@system\[-1\].hostname='\K[^']+" base-files/files/bin/config_generate | head -n 1)

# 输出日志
echo "=========================================================="
echo " 📡 当前编译固件的 LAN IP 检测结果: $DETECTED_IP "
echo " 💻 当前编译固件的主机名检测结果: $DETECTED_HOSTNAME "
echo "=========================================================="

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