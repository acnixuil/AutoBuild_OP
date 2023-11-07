# Add a feed source
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# 添加passwall
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> "feeds.conf.default"

cat>del.sh<<-\EOF
#!/bin/bash
rm -rf *kernel*
rm -rf *.manifest
rm -rf sha256sums
rm -rf *rootfs*
rm -rf profiles.json
rm -rf *.buildinfo
rm -rf *package*
rm -rf immortalwrt-x86-64-generic-squashfs-combined.vmdk
sleep 2

# 提取默认内核版本号
str1=$(grep "KERNEL_PATCHVER:=" target/linux/x86/Makefile | cut -d = -f 2)

# 构建目标文件的路径
kernel_file="include/kernel-${str1}"

# 提取内核版本号
kernel=$(grep -o "LINUX_VERSION-${str1} = .*" "$kernel_file" | cut -d ' ' -f 3)
echo "kernel=$KERNEL" >> $GITHUB_ENV

# 检查文件是否存在，然后重命名
if [ -f bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz ]; then
    mv bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz "bin/targets/x86/64/immortalwrt_x86-64_${{ env.KERNEL }}_uefi.img.gz"
fi

if [ -f bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.img.gz ]; then
    mv bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.img.gz "bin/targets/x86/64/immortalwrt_x86-64_${{ env.KERNEL }}_bios.img.gz"
fi

if [ -f bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk ]; then
    mv bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk "bin/targets/x86/64/immortalwrt_x86-64_${{ env.KERNEL }}_uefi.vmdk"
fi

exit 0
EOF