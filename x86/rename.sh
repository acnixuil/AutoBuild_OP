#!/bin/bash

rm -rf bin/targets/x86/64/packages
rm -rf bin/targets/x86/64/config.buildinfo
rm -rf bin/targets/x86/64/feeds.buildinfo
rm -rf bin/targets/x86/64/openwrt-x86-64-generic.manifest
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-kernel.bin
#rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.vmdk
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-rootfs.img.gz
rm -rf bin/targets/x86/64/profiles.json
rm -rf bin/targets/x86/64/sha256sums
rm -rf bin/targets/x86/64/version.buildinfo
sleep 2
# 获取str1的值
str1=$(grep "KERNEL_PATCHVER:=" target/linux/x86/Makefile | cut -d = -f 2)
# 构建目标文件的路径
kernel_file="include/kernel-${str1}"
# 提取内核版本号
kernel_version=$(grep -o "LINUX_VERSION-${str1} = .*" "$kernel_file" | cut -d ' ' -f 3)
# 拼接str1和kernel_version以获得完整的kernel
kernel="${str1}${kernel_version}"
# 打印kernel变量的值
echo "KERNEL=$kernel"
valid_version_regex="^[0-9]+\.[0-9]+\.[0-9]+$"
# 打印kernel变量的值
echo "KERNEL=$kernel"
sleep 2

if [[ $kernel =~ $valid_version_regex ]]; then
  echo "版本号格式合法：$kernel"

  # 直接重命名文件
  if [ -f "bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz" ]; then
    mv "bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz" "bin/targets/x86/64/openwrt_x86-64_${kernel}_bios.img.gz"
    echo "openwrt-x86-64-generic-squashfs-combined.img.gz>>openwrt_x86-64_${kernel}_bios.img.gz"
  fi

  if [ -f "bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz" ]; then
    mv "bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz" "bin/targets/x86/64/openwrt_x86-64_${kernel}_uefi.img.gz"
    echo "openwrt-x86-64-generic-squashfs-combined-efi.img.gz>>openwrt_x86-64_${kernel}_uefi.img.gz"
  fi

  if [ -f "bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk" ]; then
    mv "bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk" "bin/targets/x86/64/openwrt_x86-64_${kernel}_uefi.vmdk"
    echo "openwrt-x86-64-generic-squashfs-combined-efi.vmdk>>openwrt_x86-64_${kernel}_uefi.vmdk"
  fi
else
  echo "版本号格式不合法：$kernel"
fi
