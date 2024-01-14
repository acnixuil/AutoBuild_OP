#!/bin/bash
# Add a feed source
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# 添加passwall
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> "feeds.conf.default"

mkdir wget
# 裁剪多余文件并重命名输出文件
cat> rename.sh << 'EOF'
#!/bin/bash
#rm -rf bin/targets/x86/64/packages
rm -rf bin/targets/x86/64/config.buildinfo
rm -rf bin/targets/x86/64/feeds.buildinfo
rm -rf bin/targets/x86/64/*.manifest
rm -rf bin/targets/x86/64/*-kernel.bin
#uefi.img.gz
#rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz
#uefi.vmdk
#rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk
#bios.img.gz
#rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.img.gz
rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-combined.vmdk
rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-rootfs.tar.gz
rm -rf bin/targets/x86/64/immortalwrt-x86-64-generic-squashfs-rootfs.img.gz
rm -rf bin/targets/x86/64/profiles.json
rm -rf bin/targets/x86/64/sha256sums
rm -rf bin/targets/x86/64/version.buildinfo
sleep 2

# 获取当前默认内核版本号如5.10
str1=$(grep "KERNEL_PATCHVER:=" target/linux/x86/Makefile | cut -d = -f 2)
echo "当前默认内核版本号：${str1}"

# 检查是否存在对应版本的内核文件
kernel_file="include/kernel-${str1}"
if [ -f "$kernel_file" ]; then
    echo "文件 $kernel_file 存在."
    # 寻找版本号具体数字写入ver变量
    ver=$(grep "LINUX_VERSION-${str1} =" "$kernel_file" | cut -d . -f 3)
    echo "版本号：${ver}"

    # 构建目标文件路径
    target_path="bin/targets/x86/64/"

    # 判断是否是 6.1 版本
    if [ "$str1" = "6.1" ]; then
        if [ -z "$ver" ]; then
            # 版本号为空，表示 6.1 版本不存在，重命名到 _bios/_uefi
            echo "版本号为空，表示 6.1 版本不存在，重命名到 _bios/_uefi"
            mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined.img.gz" "${target_path}immortalwrt_x86-64_bios.img.gz"
            mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz" "${target_path}immortalwrt_x86-64_uefi.img.gz"
            mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk" "${target_path}immortalwrt_x86-64_uefi.vmdk"
        else
            # 版本号不为空，表示 6.1 版本存在，重命名到对应版本
            echo "版本号不为空，表示 6.1 版本存在，重命名到对应版本"
            mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined.img.gz" "${target_path}immortalwrt_x86-64_${str1}.${ver}_bios.img.gz"
            mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz" "${target_path}immortalwrt_x86-64_${str1}.${ver}_uefi.img.gz"
            mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk" "${target_path}immortalwrt_x86-64_${str1}.${ver}_uefi.vmdk"
        fi
    else
        # 不是 6.1 版本，重命名到对应版本
        echo "不是 6.1 版本，重命名到对应版本"
        mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined.img.gz" "${target_path}immortalwrt_x86-64_${str1}.${ver}_bios.img.gz"
        mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined-efi.img.gz" "${target_path}immortalwrt_x86-64_${str1}.${ver}_uefi.img.gz"
        mv "${target_path}immortalwrt-x86-64-generic-squashfs-combined-efi.vmdk" "${target_path}immortalwrt_x86-64_${str1}.${ver}_uefi.vmdk"
    fi
else
    echo "文件 $kernel_file 不存在."
fi
exit 0
EOF