#!/bin/bash
# 基础环境
# Alpine 设置时区和一些基础环境以及 mihomo 的脚本。
## 运行
###  apk add wget
### wget -O - https://raw.githubusercontent.com/acnixuil/AutoBuild_OP/main/alpine-mihomo.sh | sh -s -- -v
###

# 或者打自己单行复制粘贴执行。
# 不限制系统架构

set -e -o pipefail

echo "确保本 Alpine 能够正常访问 Github，TUN 已经开启"

echo "换国内源"
sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories
apk update
echo "修正时区/安装 curl、nano"
apk add tzdata curl git gzip nano
date
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone
date

ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
    'x86_64')    ARCH='amd64';;
    'x86' | 'i686' | 'i386')     ARCH='386';;
    'aarch64' | 'arm64') ARCH='arm64';;
    'armv7l')   ARCH='armv7';;
    's390x')    ARCH='s390x';;
    *)          echo "Unsupported architecture: ${ARCH_RAW}"; exit 1;;
esac
echo "当前设备架构 ${ARCH_RAW}"

VERSION=$(curl -L "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt")

echo "获取到的版本: ${VERSION}"

curl -Lo mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-${ARCH}-${VERSION}.gz"
echo "${VERSION} 下载完成，开始安装"
gzip -d mihomo.gz
chmod +x mihomo
mv mihomo /usr/local/bin/

echo "配置开机启动"
wget https://raw.githubusercontent.com/cooip-jm/About-openwrt/main/mihomo.openrc -O /etc/init.d/mihomo
chmod +x /etc/init.d/mihomo
rc-update add mihomo

# 判断是否已经存在 /etc/ui/metacubexd
# if [ ! -d "/etc/ui/metacubexd" ]; then
#     echo "安装 UI"
#     wget https://github.com/MetaCubeX/metacubexd/releases/download/v1.151.0/compressed-dist.tgz -O /tmp/compressed-dist.tgz
#     mkdir -p /etc/mihomo/ui/metacubexd
#     tar -xvzf /tmp/compressed-dist.tgz -C /etc/mihomo/ui/metacubexd
#     echo "UI 安装完成"
# else
#     echo "UI 已存在，跳过安装"
# fi

# 判断是否已经存在 /etc/ui/zashboard
if [ ! -d "/etc/ui/zashboard" ]; then
    echo "安装 UI"
    wget https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages.tar.gz -O /tmp/compressed-dist.tgz
    mkdir -p /etc/mihomo/ui/zashboard
    tar --strip-components=1 -xvzf /tmp/compressed-dist.tgz -C /etc/mihomo/ui/zashboard
    echo "UI 安装完成"
else
    echo "UI 已存在，跳过安装"
fi

# 判断是否已经存在 /etc/mihomo/config.yaml
if [ ! -f "/etc/mihomo/config.yaml" ]; then
    echo "获取懒人配置"
    wget https://wiki.metacubex.one/example/mrs -O /etc/mihomo/config.yaml
    ln -s /etc/mihomo/config.yaml /root/config.yaml
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mihomo/config.yaml
    echo "懒人配置获取完成"
else
	sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mihomo/config.yaml
    echo "/etc/mihomo/config.yaml 已存在，跳过下载"
fi

echo "nano ~/config.yaml 修改配置文件订阅内容"

echo "修改配置文件后，重启 reboot 或者使用 rc-service mihomo start"

echo "完成"
