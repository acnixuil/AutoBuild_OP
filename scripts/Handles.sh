#!/bin/bash

PKG_PATCH="$OPENWRT_PATH/package/"

#预置HomeProxy数据
if [ -d *"homeproxy"* ]; then
	HP_RULES="surge"
	HP_PATCH="homeproxy/root/etc/homeproxy"

	chmod +x ./$HP_PATCH/scripts/*
	rm -rf ./$HP_PATCH/resources/*

	git clone -q --depth=1 --single-branch --branch "release" "https://github.com/Loyalsoldier/surge-rules.git" ./$HP_RULES/
	cd ./$HP_RULES/ && RES_VER=$(git log -1 --pretty=format:'%s' | grep -o "[0-9]*")

	echo $RES_VER | tee china_ip4.ver china_ip6.ver china_list.ver gfw_list.ver
	awk -F, '/^IP-CIDR,/{print $2 > "china_ip4.txt"} /^IP-CIDR6,/{print $2 > "china_ip6.txt"}' cncidr.txt
	sed 's/^\.//g' direct.txt > china_list.txt ; sed 's/^\.//g' gfw.txt > gfw_list.txt
	mv -f ./{china_*,gfw_list}.{ver,txt} ../$HP_PATCH/resources/

	cd .. && rm -rf ./$HP_RULES/

	cd $PKG_PATCH && echo "homeproxy date has been updated!"
fi

#预置OpenClash内核和数据
if [ -d *"openclash"* ]; then
	CORE_VER="https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version"
	CORE_TYPE=$CLASH_KERNEL
	CORE_TUN_VER=$(curl -sL $CORE_VER | sed -n "2{s/\r$//;p;q}")

	CORE_DEV="https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-$CORE_TYPE.tar.gz"
	CORE_MATE="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"
	CORE_TUN="https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-$CORE_TYPE-$CORE_TUN_VER.gz"

	GEO_MMDB="https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb"
	GEO_SITE="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat"
	GEO_IP="https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat"

	cd ./luci-app-openclash/root/etc/openclash/

	curl -sL -o Country.mmdb $GEO_MMDB && echo "Country.mmdb done!"
	curl -sL -o GeoSite.dat $GEO_SITE && echo "GeoSite.dat done!"
	curl -sL -o GeoIP.dat $GEO_IP && echo "GeoIP.dat done!"

	mkdir ./core/ && cd ./core/

	curl -sL -o meta.tar.gz $CORE_MATE && tar -zxf meta.tar.gz && mv -f clash clash_meta && echo "meta done!"
	curl -sL -o tun.gz $CORE_TUN && gzip -d tun.gz && mv -f tun clash_tun && echo "tun done!"
	curl -sL -o dev.tar.gz $CORE_DEV && tar -zxf dev.tar.gz && echo "dev done!"

	chmod +x ./* && rm -rf ./*.gz

	cd $PKG_PATCH && echo "openclash date has been updated!"
fi

# 预置AdGuardHome数据
if [ -d *"adguardhome"* ]; then
    AGH_PATCH="luci-app-adguardhome/root/usr/bin/AdGuardHome"

    mkdir -p ./$AGH_PATCH

    # 直接使用环境变量$CLASH_KERNEL来确定下载哪个版本的AdGuardHome
    AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep /AdGuardHome_linux_${CLASH_KERNEL} | awk -F '"' '{print $4}')

    wget -qO- $AGH_CORE | tar xOvz > ./$AGH_PATCH/AdGuardHome

    chmod +x ./$AGH_PATCH/AdGuardHome

    cd $PKG_PATCH && echo "AdGuardHome data has been updated!"
fi

# 替换背景图像
if [ -d "$PKG_PATCH/luci-theme-argon" ]; then
    cp -f $GITHUB_WORKSPACE/images/bg1.jpg $PKG_PATCH/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
    cd $PKG_PATCH && echo "Background image has been updated!"
fi

# 修改 amlogic 配置
if [ -d "$PKG_PATCH/luci-app-amlogic ]; then
    sed -i "s|ARMv8|ARMv8|g" "$PKG_PATCH/luci-app-amlogic/luci-app-amlogic/root/etc/config/amlogic
    cd $PKG_PATCH && echo "Amlogic configuration has been updated!"
fi