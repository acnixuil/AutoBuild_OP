# sed -i '$a src-git helloworld https://github.com/fw876/helloworld' feeds.conf.default

# passwall
#sed -i '$a src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall.git;packages' feeds.conf.default
#sed -i '$a src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;luci' feeds.conf.default

mkdir wget
cat>rename.sh<<-\EOF
#!/bin/bash
rm -rf *kernel*
rm -rf *.manifest
rm -rf sha256sums
rm -rf package
rm -rf *rootfs*
rm -rf profiles.json
rm -rf *.buildinfo
sleep 2
mv bin/targets/*/*/openwrt-ipq60xx-generic-zn_m2-squashfs-nand-factory bin/targets/*/*/openwrt_ipq60xx_factory.ubi
mv bin/targets/*/*/openwrt-ipq60xx-generic-zn_m2-squashfs-nand-sysupgrade.bin bin/targets/*/*/openwrt_ipq60xx_sysupgrade.bin
exit 0
EOF