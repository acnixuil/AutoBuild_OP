#!/bin/bash
PKG_PATCH="$GITHUB_WORKSPACE/openwrt/package"

# 预置HomeProxy数据
if [ -d "./homeproxy" ]; then
    echo "HomeProxy目录已找到!"
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
	echo "HomeProxy数据更新完成"
	cd "$PKG_PATCH" || exit
fi

# 预置OpenClash内核和数据
if [ -d "./luci-app-openclash" ]; then
    echo "OpenClash目录已找到!"
	CORE_TYPE=$CLASH_KERNEL
	CORE_META="https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-$CORE_TYPE.tar.gz"
	GEO_IP="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
	GEO_SITE="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
	GEO_MMDB="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb"

	cd ./luci-app-openclash/root/etc/openclash/
	curl -sL -o Country.mmdb $GEO_MMDB && echo "Country.mmdb done!"
	curl -sL -o GeoSite.dat $GEO_SITE && echo "GeoSite.dat done!"
	curl -sL -o GeoIP.dat $GEO_IP && echo "GeoIP.dat done!"

	mkdir ./core/ && cd ./core/
	curl -sL -o meta.tar.gz $CORE_META && tar -zxf meta.tar.gz && mv -f clash clash_meta && echo "meta done!"

	chmod +x ./* && rm -rf ./*.gz
	echo "OpenClash数据更新完成"
	cd "$PKG_PATCH" || exit
fi

# 输出当前目录内容
echo "检查Mihomo目录: $(pwd)"
ls

# 预置Mihomo数据
if [ -d "./mihomo" ]; then
    echo "Mihomo目录已找到!"
    GEO_IP="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geoip-lite.dat"
    GEO_SITE="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/geosite.dat"
    GEO_MMDB="https://github.com/MetaCubeX/meta-rules-dat/releases/download/latest/GeoLite2-ASN.mmdb"
	mkdir -p ./mihomo/luci-app-mihomo/root/etc/mihomo/run
    cd ./mihomo/luci-app-mihomo/root/etc/mihomo/run

    curl -sL -o ASN.mmdb $GEO_MMDB && echo "ASN.mmdb done!"
    curl -sL -o geosite.dat $GEO_SITE && echo "GeoSite.dat done!"
    curl -sL -o geoip.dat $GEO_IP && echo "GeoIP.dat done!"
	echo "Mihomo数据更新完成"
	cd "$PKG_PATCH" || exit
fi

# 预置AdGuardHome数据
if [ -d "./luci-app-adguardhome" ]; then
    echo "AdGuardHome目录已找到!"
    AGH_PATCH="luci-app-adguardhome/root/usr/bin/AdGuardHome"

    mkdir -p ./$AGH_PATCH

    AGH_CORE=$(curl -sL https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest | grep /AdGuardHome_linux_${CLASH_KERNEL} | awk -F '"' '{print $4}')
    wget -qO- $AGH_CORE | tar xOvz > ./$AGH_PATCH/AdGuardHome

    chmod +x ./$AGH_PATCH/AdGuardHome
	echo "AdGuardHome数据更新完成"
	cd "$PKG_PATCH" || exit
fi

# 替换背景图像
if [ -d "./luci-theme-argon" ]; then
    cp -f $GITHUB_WORKSPACE/images/bg1.jpg luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
    echo "默认壁纸替换完成"
	cd $PKG_PATCH || exit
fi

# 修改amlogic配置
if [ -d "./luci-app-amlogic" ]; then
    echo "Amlogic目录已找到!"
    CONFIG_FILE="./luci-app-amlogic/luci-app-amlogic/root/etc/config/amlogic"
    sed -i "s/ARMv8/ARMv8/g" "$CONFIG_FILE"
	echo "Amlogic数据更新完成"
	cd "$PKG_PATCH" || exit
fi

echo "脚本执行完成!"