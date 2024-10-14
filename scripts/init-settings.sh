#!/bin/bash

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/bootstrap'
uci commit luci
echo "已修改默认主题为bootstrap"
# Disable IPV6 ula prefix
# sed -i 's/^[^#].*option ula/#&/' /etc/config/network

# Check file system during boot
# uci set fstab.@global[0].check_fs=1
# uci commit fstab

# zerotier
sed -i 's/services/vpn/g' feeds/luci/applications/luci-app-zerotier/root/usr/share/luci/menu.d/luci-app-zerotier.json
# 改名
sed -i 's/msgstr "UPnP IGD 和 PCP\/NAT-PMP"/msgstr "UPnP"/' feeds/luci/applications/luci-app-upnp/po/zh_Hans/upnp.po

exit 0
