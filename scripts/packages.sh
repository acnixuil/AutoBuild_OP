#!/bin/bash
#
# 在 openwrt/package 目录下执行（Build-OpenWrt.yml 的「下载第三方包」步骤会 cd 到这里）。
# 职责：清掉 feeds 里会被重复定义的插件 -> 拉 Golang 运行时 -> 拉各插件与主题 -> 按版本拉高版本专属插件。
#
# 约定：所有克隆都落在当前目录（package/），目录名就是包名；luci 插件必须是 package/<包名>/Makefile 这一层，
#      luci.mk 从 ../feeds/luci/ 取。

# --- 输出样式 ---
GREEN="\033[0;32m"
BLUE="\033[1;34m"
RESET="\033[0m"

log() {
    echo -e "${BLUE}==>${RESET} $1"
}

section() {
    echo -e "\n${GREEN}==== $1 ====${RESET}"
}

# --- 识别源码版本 ---
# 结果：21.02 -> 2102，23.05 -> 2305，24.10 -> 2410，25.12 -> 2512；SNAPSHOT 等非数字版本号记为 9999。
DETECTED_VERSION="unknown"
VERSION_NUM=0

if [ -f "../include/version.mk" ]; then
    VERSION_RAW=$(grep -E '^VERSION_NUMBER:=\$\(if.*,' ../include/version.mk | head -n 1 | awk -F',' '{print $NF}' | tr -d ' )')
    DETECTED_VERSION=$(printf '%s' "$VERSION_RAW" | grep -oE '^[0-9]+\.[0-9]+')
    if [ -n "$DETECTED_VERSION" ]; then
        VERSION_NUM=$(echo "$DETECTED_VERSION" | tr -d '.')
    elif [ -n "$VERSION_RAW" ]; then
        DETECTED_VERSION="$VERSION_RAW"
        VERSION_NUM=9999
    fi
fi

if [ "$VERSION_NUM" -ge 9999 ]; then
    echo ">> 当前源码主版本: ${DETECTED_VERSION}（非数字版本号，按最新源码处理）"
else
    echo ">> 当前源码主版本: ${DETECTED_VERSION:-没匹配到数字版本}"
fi

# --- 清理 feeds 里的同名插件 ---
# 下面会自己克隆一份到 package/，feeds 里若也有同名包会造成重复定义，先删干净。
section "清理 feeds 同名插件"

for pkg in openclash lucky adguardhome argon rtp2httpd luci-theme-carbon; do
    find ../feeds -name "*${pkg}*" -exec rm -rf {} + 2>/dev/null
done

# --- Golang 运行时 ---
# sing-box、mihomo 这些要用较新的 Go，feeds 自带的版本不够，统一换成 sbwml 的 27.x。
section "更新 Golang 运行时"

rm -rf ../feeds/packages/lang/golang
git clone https://github.com/sbwml/packages_lang_golang -b 27.x ../feeds/packages/lang/golang

# --- 稀疏克隆工具 ---
# 用法：git_sparse_clone <分支> <仓库地址> <要取的目录> [更多目录...]
# 取到的目录会被移动到 package/ 下，临时目录自动删除。
git_sparse_clone() {
    branch="$1" repourl="$2" && shift 2
    tmpdir="$(basename -s .git "$repourl")_tmp"
    git clone --depth=1 -b "$branch" --single-branch --filter=blob:none --sparse "$repourl" "$tmpdir"
    cd "$tmpdir" || exit 1
    git sparse-checkout set "$@"
    mv -f "$@" ../
    cd .. && rm -rf "$tmpdir"
}

# --- 代理与拦截 ---
section "OpenClash / AdGuardHome"

git_sparse_clone dev https://github.com/vernesong/OpenClash luci-app-openclash
git clone --depth=1 --single-branch -b master https://github.com/acnixuil/luci-app-adguardhome.git luci-app-adguardhome

# --- Lucky ---
# 内核和前端分属两个仓库：内核取官方 gdy666 的 lucky/，前端取 sirpdboy 的 luci-app-lucky/。
# 内核版本由 patch/lucky/Makefile 钉死（3.8.0 xiaojv），这里只负责把源码目录摆到位。
section "Lucky 内核与前端"

git_sparse_clone main https://github.com/gdy666/luci-app-lucky lucky
git_sparse_clone main https://github.com/sirpdboy/luci-app-lucky luci-app-lucky

# --- 主题 ---
section "LuCI 主题"

git clone --depth=1 --single-branch -b master https://github.com/yhl452493373/luci-theme-argon luci-theme-argon
git clone --depth=1 --single-branch -b master https://github.com/jerrykuku/luci-app-argon-config.git luci-app-argon-config

# Carbon 只支持 ucode 版 LuCI（23.05 起）
if [ "$VERSION_NUM" -ge 2305 ]; then
    log "添加 luci-theme-carbon"
    git clone --depth=1 --single-branch -b main https://github.com/mrjoechen/luci-theme-carbon.git luci-theme-carbon
else
    echo ">> 当前固件版本 ($DETECTED_VERSION) < 23.05，跳过 luci-theme-carbon（需要 ucode 版 LuCI）"
fi

# --- rtp2httpd ---
# 仓库自带的 Makefile 靠 git 仓库结构取版本，所以用它的 Makefile.versioned 顶替，改成按版本号下载源码包。
section "rtp2httpd"

git_sparse_clone main https://github.com/stackia/rtp2httpd.git openwrt-support
mv -f openwrt-support/rtp2httpd/Makefile.versioned openwrt-support/rtp2httpd/Makefile
mv -f openwrt-support/luci-app-rtp2httpd/Makefile.versioned openwrt-support/luci-app-rtp2httpd/Makefile

# --- 高版本专属插件 ---
# 这批插件依赖 24.10 以上的 ucode / luci 接口，低版本不拉。
if [ "$VERSION_NUM" -ge 2410 ]; then
    section "高版本专属插件（>= 24.10）"
    echo ">> 当前固件版本 ($DETECTED_VERSION) >= 24.10，开始拉取"

    find ../ -name '*v2ray-geodata*' -exec rm -rf {} + 2>/dev/null
    find ../ -name '*mosdns*' -exec rm -rf {} + 2>/dev/null
    find ../feeds -name '*nikki*' -exec rm -rf {} + 2>/dev/null
    find ../feeds -name '*diskman*' -exec rm -rf {} + 2>/dev/null

    git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-nikki.git nikki
    git clone --depth=1 --single-branch -b main https://github.com/nikkinikki-org/OpenWrt-momo.git momo
    git clone --depth=1 --single-branch -b main https://github.com/VizzleTF/luci-theme-footstrap.git luci-theme-footstrap
    git clone --depth=1 --single-branch -b main https://github.com/sbwml/luci-app-diskman luci-app-diskman
    git clone --depth=1 --single-branch -b v5 https://github.com/sbwml/luci-app-mosdns.git mosdns
    git clone --depth=1 --single-branch -b master https://github.com/sbwml/v2ray-geodata.git v2ray-geodata
else
    echo ">> 当前固件版本 ($DETECTED_VERSION) < 24.10，跳过高版本专属插件"
fi
