#!/bin/bash
#============================================================
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
# Lisence: MIT
# Author: P3TERX
# Blog: https://p3terx.com
#============================================================

# 修改内核版本
sed -i '/.*KERNEL_PATCHVER*/c\KERNEL_PATCHVER:=5.15' /home/lede/target/linux/x86/Makefile
# 修改网关ip
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate
# 取消登录密码
sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/lean/default-settings/files/zzz-default-settings
# 修改默认主题
#sed -i 's/luci-theme-argon/luci-theme-bootstrap/' feeds/luci/collections/luci/Makefile