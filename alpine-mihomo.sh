#!/bin/bash
set -e -o pipefail

echo "[1] 检查网络访问 Github..."
ping -c 1 github.com || {
  echo "❌ 无法访问 GitHub，退出"; exit 1;
}

echo "[2] 安装基础环境（curl、nano、git）"
apk update
apk add tzdata curl git gzip nano bash --no-cache

echo "[3] 设置时区"
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
echo "Asia/Shanghai" > /etc/timezone
date

echo "[4] 检查 CPU 架构"
ARCH_RAW=$(uname -m)
case "${ARCH_RAW}" in
    'x86_64')    ARCH='amd64';;
    'x86' | 'i686' | 'i386') ARCH='386';;
    'aarch64' | 'arm64')     ARCH='arm64';;
    'armv7l')     ARCH='armv7';;
    *) echo "❌ Unsupported architecture: ${ARCH_RAW}"; exit 1;;
esac
echo "当前架构：${ARCH_RAW} (${ARCH})"

echo "[5] 获取 mihomo 最新版本号..."
VERSION=$(curl -fsSL "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/version.txt")
echo "版本号：${VERSION}"

echo "[6] 下载 mihomo 主程序..."
curl -fLo mihomo.gz "https://github.com/MetaCubeX/mihomo/releases/download/Prerelease-Alpha/mihomo-linux-${ARCH}-${VERSION}.gz"
gzip -d mihomo.gz
chmod +x mihomo
mv mihomo /usr/local/bin/

echo "[7] 配置开机启动服务..."
wget -q https://raw.githubusercontent.com/cooip-jm/About-openwrt/main/mihomo.openrc -O /etc/init.d/mihomo
chmod +x /etc/init.d/mihomo
rc-update add mihomo default

echo "[8] 安装 UI（zashboard）..."
if [ ! -d "/etc/ui/zashboard" ]; then
    mkdir -p /etc/mihomo/ui/zashboard
    wget -q https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages.tar.gz -O /tmp/zashboard.tgz
    tar --strip-components=1 -xzf /tmp/zashboard.tgz -C /etc/mihomo/ui/zashboard
    echo "✅ UI 安装完成"
else
    echo "🔁 UI 已存在，跳过安装"
fi

echo "[9] 下载默认配置..."
mkdir -p /etc/mihomo
if [ ! -f "/etc/mihomo/config.yaml" ]; then
    wget -q https://github.com/JohnsonRan/CRules/blob/master/config/AIB.yaml -O /etc/mihomo/config.yaml
    ln -sf /etc/mihomo/config.yaml /root/config.yaml
fi
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mihomo/config.yaml

echo "📄 nano ~/config.yaml 修改订阅配置"
echo "✅ 安装完成！使用以下命令启动或重启 mihomo："
echo "  rc-service mihomo start"
echo "或者 reboot 重启容器"
