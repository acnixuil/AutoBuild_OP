# Add a feed source
#sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# passwall
echo "src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main" >> "feeds.conf.default"
echo "src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main" >> "feeds.conf.default"

mkdir wget
# 裁剪多余文件并重命名输出文件
cat>rename.sh<<-\EOF
#!/bin/bash
rm -rf bin/targets/x86/64/packages
rm -rf bin/targets/x86/64/config.buildinfo
rm -rf bin/targets/x86/64/feeds.buildinfo
rm -rf bin/targets/x86/64/openwrt-x86-64-generic.manifest
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-kernel.bin
#rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.vmdk
rm -rf bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz
rm -rf bin/targets/x86/64/*-rootfs.*
rm -rf bin/targets/x86/64/profiles.json
rm -rf bin/targets/x86/64/sha256sums
rm -rf bin/targets/x86/64/version.buildinfo
sleep 2
str1=`grep "KERNEL_PATCHVER:="  target/linux/x86/Makefile | cut -d = -f 2` #判断当前默认内核版本号如5.10
ver54=`grep "LINUX_VERSION-5.4 ="  include/kernel-5.4 | cut -d . -f 3`
ver515=`grep "LINUX_VERSION-5.15 ="  include/kernel-5.15 | cut -d . -f 3`
ver61=`grep "LINUX_VERSION-6.1 ="  include/kernel-6.1 | cut -d . -f 3`
if [ "$str1" = "5.4" ];then
#   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/openwrt_x86-64_${str1}.${ver54}_bios.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/openwrt_x86-64_${str1}.${ver54}_uefi.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk     bin/targets/x86/64/openwrt_x86-64_${str1}.${ver54}_uefi.vmdk
elif [ "$str1" = "5.15" ];then
#   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/openwrt_x86-64_${str1}.${ver515}_bios.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/openwrt_x86-64_${str1}.${ver515}_uefi.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk     bin/targets/x86/64/openwrt_x86-64_${str1}.${ver515}_uefi.vmdk
elif [ "$str1" = "6.1" ];then
   if [ ! $ver61 ]; then
#   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/openwrt_x86-64_${str1}.${ver61}0_bios.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/openwrt_x86-64_${str1}.${ver61}0_uefi.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk     bin/targets/x86/64/openwrt_x86-64_uefi.vmdk
  else
#   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined.img.gz       bin/targets/x86/64/openwrt_x86-64_${str1}.${ver61}_bios.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.img.gz   bin/targets/x86/64/openwrt_x86-64_${str1}.${ver61}_uefi.img.gz
   mv  bin/targets/x86/64/openwrt-x86-64-generic-squashfs-combined-efi.vmdk     bin/targets/x86/64/openwrt_x86-64_${str1}.${ver61}_uefi.vmdk
   fi
fi
#md5
ls -l  "bin/targets/x86/64" | awk -F " " '{print $9}' > wget/open_dev_md5
dev_version=`grep "_uefi.img.gz" wget/open_dev_md5 | cut -d - -f 2 | cut -d _ -f 2 `
openwrt_dev=openwrt_x86-64_${dev_version}_bios.img.gz
openwrt_dev_uefi=openwrt_x86-64_${dev_version}_uefi.img.gz
cd bin/targets/x86/64
#md5sum $openwrt_dev > openwrt_bios.md5
#md5sum $openwrt_dev_uefi > openwrt_uefi.md5
exit 0
EOF
