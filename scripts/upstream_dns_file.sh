#!/bin/bash

# 创建目标目录（如果不存在）
mkdir -p "files/etc"

# 下载文件并保存到指定目录
wget -O "files/etc/dns.txt" "https://github.com/acnixuil/FAK-DNS/releases/download/dns/FAK-DNS.txt" || curl -o "files/etc/FAK-DNS.txt" -L "https://github.com/acnixuil/FAK-DNS/releases/download/dns/FAK-DNS.txt"

# 检查文件是否成功下载
if [ $? -eq 0 ]; then
    echo "文件下载成功，正在修改权限..."
    # 修改文件权限为可执行
    chmod +x "files/etc/dns.txt"
    echo "完成。文件已保存到 files/etc/dns.txt 并设置为可执行状态。"
else
    echo "文件下载失败，请检查URL或网络连接。"
fi