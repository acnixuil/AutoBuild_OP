#!/bin/bash
#============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/lean/default-settings/files/zzz-default-settings
echo "# ip6tables -A input_lan_rule -i br-lan -p ipv6-icmp -m mac ! --mac-source NAS_MAC -j DROP" >> package/network/config/firewall/files/firewall.user
echo "# ip6tables -A input_lan_rule -i br-lan -p udp --dport 547 -m mac ! --mac-source NAS_MAC  -j DROP" >> package/network/config/firewall/files/firewall.user
