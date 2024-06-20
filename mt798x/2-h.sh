#!/bin/bash
#============================================================
# 以下部分为更新并安装feeds后后后运行
#============================================================

# Modify default IP
sed -i 's/192.168.6.1/192.168.2.1/g' package/base-files/files/bin/config_generate

#安装和更新软件包
UPDATE_PACKAGE() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_BRANCH=$3
	local PKG_SPECIAL=$4
	local REPO_NAME=$(echo $PKG_REPO | cut -d '/' -f 2)

	rm -rf $(find ../feeds/luci/ -type d -iname "*$PKG_NAME*" -prune)

	git clone --depth=1 --single-branch --branch $PKG_BRANCH "https://github.com/$PKG_REPO.git"

	if [[ $PKG_SPECIAL == "pkg" ]]; then
		cp -rf $(find ./$REPO_NAME/ -type d -iname "*$PKG_NAME*" -prune) ./
		rm -rf ./$REPO_NAME/
	elif [[ $PKG_SPECIAL == "name" ]]; then
		mv -f $REPO_NAME $PKG_NAME
	fi
}

UPDATE_PACKAGE "design" "gngpp/luci-theme-design" "js"
UPDATE_PACKAGE "design-config" "gngpp/luci-app-design-config" "master"
UPDATE_PACKAGE "argon" "jerrykuku/luci-theme-argon" "master"
UPDATE_PACKAGE "argon-config" "jerrykuku/luci-app-argon-config" "master"

UPDATE_PACKAGE "helloworld" "fw876/helloworld" "master"
UPDATE_PACKAGE "mihomo" "morytyann/OpenWrt-mihomo" "main"
UPDATE_PACKAGE "openclash" "vernesong/OpenClash" "dev"
UPDATE_PACKAGE "passwall" "xiaorouji/openwrt-passwall" "main"

UPDATE_PACKAGE "adguardhome" "acnixuil/luci-app-adguardhome" "master"
UPDATE_PACKAGE "neko" "nosignals/neko" "luci-app-neko"
UPDATE_PACKAGE "mosdns" "sbwml/luci-app-mosdns" "v5"
UPDATE_PACKAGE "lucky" "gdy666/luci-app-lucky" "main"
}

#更新软件包版本
UPDATE_VERSION() {
	local PKG_NAME=$1
	local PKG_REPO=$2
	local PKG_MARK=${3:-not}
	local PKG_FILE=$(find ../feeds/packages/*/$PKG_NAME/ -type f -name "Makefile" 2>/dev/null)

	if [ -f "$PKG_FILE" ]; then
		echo "$PKG_NAME version update has started!"

		local OLD_VER=$(grep -Po "PKG_VERSION:=\K.*" $PKG_FILE)
		local PKG_VER=$(curl -sL "https://api.github.com/repos/$PKG_REPO/releases" | jq -r "map(select(.prerelease|$PKG_MARK)) | first | .tag_name")
		local NEW_VER=$(echo $PKG_VER | sed "s/.*v//g; s/_/./g")
		local NEW_HASH=$(curl -sL "https://codeload.github.com/$PKG_REPO/tar.gz/$PKG_VER" | sha256sum | cut -b -64)

		echo "$OLD_VER $PKG_VER $NEW_VER $NEW_HASH"

		if dpkg --compare-versions "$OLD_VER" lt "$NEW_VER"; then
			sed -i "s/PKG_VERSION:=.*/PKG_VERSION:=$NEW_VER/g" $PKG_FILE
			sed -i "s/PKG_HASH:=.*/PKG_HASH:=$NEW_HASH/g" $PKG_FILE
			echo "$PKG_NAME version has been updated!"
		else
			echo "$PKG_NAME version is already the latest!"
		fi

		echo " "
	else
		echo "$PKG_NAME not found!"
	fi
}

#UPDATE_VERSION "软件包名" "项目地址" "测试版true（可选，默认为否）"
UPDATE_VERSION "brook" "txthinking/brook"
UPDATE_VERSION "dns2tcp" "zfl9/dns2tcp"
UPDATE_VERSION "hysteria" "apernet/hysteria"
UPDATE_VERSION "ipt2socks" "zfl9/ipt2socks"
UPDATE_VERSION "microsocks" "rofl0r/microsocks"
UPDATE_VERSION "naiveproxy" "klzgrad/naiveproxy"
UPDATE_VERSION "sing-box" "SagerNet/sing-box" "true"
UPDATE_VERSION "trojan-go" "p4gefau1t/trojan-go"
UPDATE_VERSION "trojan" "trojan-gfw/trojan"
UPDATE_VERSION "v2ray-core" "v2fly/v2ray-core"
UPDATE_VERSION "v2ray-plugin" "teddysun/v2ray-plugin"
UPDATE_VERSION "xray-core" "XTLS/Xray-core"
UPDATE_VERSION "xray-plugin" "teddysun/xray-plugin"

# 更新 golang 1.22 版本
rm -rf feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 22.x feeds/packages/lang/golang

## customize lucky ver
# wget https://www.daji.it:6/files/$(PKG_VERSION)/$(PKG_NAME)_$(PKG_VERSION)_Linux_$(LUCKY_ARCH).tar.gz
lkver=2.5.3
sed -i 's/PKG_VERSION:=.*/PKG_VERSION:='"$lkver"'/g;s/github.com\/gdy666\/lucky\/releases\/download\/v/www.daji.it\:6\/files\//g' package/custom/lucky/lucky/Makefile

# 更改 Argon 主题背景
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg
perl -0777 -i -pe 's|<footer class="mobile-hide">\s*<div>.*?</div>\s*</footer>|<footer class="mobile-hide">\n\t<div>\n\t</div>\n</footer>|s' package/luci-theme-argon/luasrc/view/themes/argon/footer.htm
perl -0777 -i -pe 's|<footer>\s*<div>.*?</div>\s*</footer>|<footer>>\n\t<div>\n\t</div>\n</footer>|s' package/luci-theme-argon/luasrc/view/themes/argon/footer_login.htm

#修改默认WIFI名
WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
sed -i "/htbsscoex=\"1\"/{n; s/ssid=\".*\"/ssid=\"大吉99_2.4G\"/}" $WIFI_FILE
sed -i "/htbsscoex=\"0\"/{n; s/ssid=\".*\"/ssid=\"大吉99\"/}" $WIFI_FILE