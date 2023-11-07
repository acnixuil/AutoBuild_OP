# Add a feed source
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# passwall
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> "feeds.conf.default"

mkdir wget

cat>del.sh<<-\EOF
#!/bin/bash
rm -rf packages
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
# 提取默认内核版本号
str1=$(grep "KERNEL_PATCHVER:=" target/linux/x86/Makefile | cut -d = -f 2)

# 构建目标文件的路径
kernel_file="include/kernel-${str1}"

# 提取内核版本号
kernel=$(grep -o "LINUX_VERSION-${str1} = .*" "$kernel_file" | cut -d ' ' -f 3)
echo "kernel=$KERNEL" >> $GITHUB_ENV
exit 0
EOF

cat>rename.sh<<-\EOF
#!/bin/bash
# 检查文件是否存在，然后重命名
if [ -f openwrt-x86-64-generic-squashfs-combined-efi.img.gz ]; then
    mv bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz "openwrt_x86-64_${{ env.KERNEL }}_uefi.img.gz"
fi

if [ -f openwrt-x86-64-generic-squashfs-combined.img.gz ]; then
    mv openwrt-x86-64-generic-squashfs-combined.img.gz "openwrt_x86-64_${{ env.KERNEL }}_bios.img.gz"
fi

if [ -f openwrt-x86-64-generic-squashfs-combined-efi.vmdk ]; then
    mv openwrt-x86-64-generic-squashfs-combined-efi.vmdk "openwrt_x86-64_${{ env.KERNEL }}_uefi.vmdk"
fi
exit 0
EOF
