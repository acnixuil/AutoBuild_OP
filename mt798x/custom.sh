#!/bin/bash

# 修改网关ip
sed -i 's/192\.168\.1\.[0-9]\{1,3\}/192.168.5.1/g' base-files/files/bin/config_generate

echo "定制化设置已完成"