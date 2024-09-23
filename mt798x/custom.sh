#!/bin/bash

# 修改网关ip
sed -i 's/192\.168\.1\.[0-9]\{1,3\}/192.168.5.1/g' base-files/files/bin/config_generate

#修改默认WIFI名
WIFI_FILE="mtk/applications/mtwifi-cfg/files/mtwifi.sh"
sed -i "/htbsscoex=\"1\"/{n; s/ssid=\".*\"/ssid=\"万事大吉_2.4G\"/}" $WIFI_FILE
sed -i "/htbsscoex=\"0\"/{n; s/ssid=\".*\"/ssid=\"万事大吉\"/}" $WIFI_FILE

echo "定制化设置已完成"