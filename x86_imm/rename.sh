#!/bin/bash

# 删除文件
rm -rf bin/targets/x86/64/packages
rm -rf bin/targets/x86/64/config.buildinfo
rm -rf bin/targets/x86/64/feeds.buildinfo
rm -rf bin/targets/x86/64/*.manifest
rm -rf bin/targets/x86/64/*-kernel.bin
#rm -rf bin/targets/x86/64/*-efi.vmdk
rm -rf bin/targets/x86/64/*-combined.vmdk
rm -rf bin/targets/x86/64/*-combined.img.gz
rm -rf bin/targets/x86/64/*-rootfs.*
rm -rf bin/targets/x86/64/profiles.json
rm -rf bin/targets/x86/64/sha256sums
rm -rf bin/targets/x86/64/version.buildinfo
sleep 2

# 获取内核版本
str1=$(grep "KERNEL_PATCHVER:=" target/linux/x86/Makefile | cut -d = -f 2)
kernel_file="include/kernel-${str1}"
kernel_version=$(grep -o "LINUX_VERSION-${str1} = .*" "$kernel_file" | cut -d ' ' -f 3)
kernel="${str1}${kernel_version}"

echo "Kernel version: $kernel"

# 重命名文件
if [ -f bin/targets/x86/64/*-efi.img.gz ]; then
    mv bin/targets/x86/64/*-efi.img.gz "bin/targets/x86/64/immortalwrt_x86-64_${kernel}_uefi.img.gz"
fi

if [ -f bin/targets/x86/64/*-combined.img.gz ]; then
    mv bin/targets/x86/64/*-combined.img.gz "bin/targets/x86/64/immortalwrt_x86-64_${kernel}_bios.img.gz"
fi

if [ -f bin/targets/x86/64/*-efi.vmdk ]; then
    mv bin/targets/x86/64/*-efi.vmdk "bin/targets/x86/64/immortalwrt_x86-64_${kernel}_uefi.vmdk"
fi