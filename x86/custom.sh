#!/bin/bash

# 修改网关ip
sed -i 's/192\.168\.1\.[0-9]\{1,3\}/192.168.3.1/g' base-files/files/bin/config_generate

# 取消登录密码
sed -i '/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF./d' lean/default-settings/files/zzz-default-settings

# 调整 x86 型号只显示 CPU 型号
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}/g' lean/autocore/files/x86/autocore

echo "定制化设置已完成"