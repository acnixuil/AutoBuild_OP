#!/bin/bash

# 删除文件
rm -rf bin/targets/x86/64/packages
rm -rf bin/targets/x86/64/config.buildinfo
rm -rf bin/targets/x86/64/feeds.buildinfo
rm -rf bin/targets/x86/64/*.manifest
rm -rf bin/targets/x86/64/*-kernel.bin
#rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz
#rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk
#rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.img.gz
rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.vmdk
rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-rootfs.tar.gz
rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-rootfs.img.gz
rm -rf bin/targets/x86/64/profiles.json
rm -rf bin/targets/x86/64/sha256sums
rm -rf bin/targets/x86/64/version.buildinfo
sleep 2

# 获取内核版本
str1=$(grep "KERNEL_PATCHVER:=" target/linux/x86/Makefile | cut -d = -f 2)
kernel_file="include/kernel-${str1}"
kernel_version=$(grep -o "LINUX_VERSION-${str1} = .*" "$kernel_file" | cut -d ' ' -f 3)
kernel="${str1}${kernel_version}"
valid_version_regex="^[0-9]+\.[0-9]+\.[0-9]+$"
# 打印kernel变量的值
echo "KERNEL=$kernel"
sleep 2

if [[ $kernel =~ $valid_version_regex ]]; then
  echo "版本号格式合法：$kernel"

  # 直接重命名文件
  if [ -f "bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.img.gz" ]; then
    mv "bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.img.gz" "bin/targets/x86/64/immortalwrt_x86-64_${kernel}_bios.img.gz"
    echo "immortalwrt-x86-64-generic-squashfs-combined.img.gz>>immortalwrt_x86-64_${kernel}_bios.img.gz"
  fi

  if [ -f "bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz" ]; then
    mv "bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz" "bin/targets/x86/64/immortalwrt_x86-64_${kernel}_uefi.img.gz"
    echo "immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz>>immortalwrt_x86-64_${kernel}_uefi.img.gz"
  fi

  if [ -f "bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk" ]; then
    mv "bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk" "bin/targets/x86/64/immortalwrt_x86-64_${kernel}_uefi.vmdk"
    echo "immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk>>immortalwrt_x86-64_${kernel}_uefi.vmdk"
  fi
else
  echo "版本号格式不合法：$kernel"
fi