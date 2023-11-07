# Add a feed source
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# passwall
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> "feeds.conf.default"

# 裁剪多余文件并重命名输出文件
cat <<EOL > del.sh
#!/bin/bash
rm -rf packages
rm -rf bin/targets/x86/64/config.buildinfo
rm -rf bin/targets/x86/64/feeds.buildinfo
rm -rf bin/targets/x86/64/openwrt-x86-64-generic.manifest
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-kernel.bin
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.vmdk
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-rootfs.img.gz
rm -rf bin/targets/x86/64/profiles.json
rm -rf bin/targets/x86/64/sha256sums
rm -rf bin/targets/x86/64/version.buildinfo
sleep 2

# 提取默认内核版本号
str1=\$(grep "KERNEL_PATCHVER:=" target/linux/x86/Makefile | cut -d = -f 2)

# 构建目标文件的路径
kernel_file="include/kernel-\$str1"

# 提取内核版本号
Kernel=\$(grep -o "LINUX_VERSION-\$str1 = .*" "\$kernel_file" | cut -d ' ' -f 3)
echo "内核版本为${Kernel}"
echo "KERNEL=$Kernel" >> \$GITHUB_ENV

# 检查文件是否存在，然后重命名
if [ -f bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz ]; then
    mv bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz "bin/targets/x86/64/openwrt_x86-64_${Kernel}_uefi.img.gz"
fi

if [ -f bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz ]; then
    mv bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz "bin/targets/x86/64/openwrt_x86-64_${Kernel}_bios.img.gz"
fi

if [ -f bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk ]; then
    mv bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk "bin/targets/x86/64/openwrt_x86-64_${Kernel}_uefi.vmdk"
fi
EOL
