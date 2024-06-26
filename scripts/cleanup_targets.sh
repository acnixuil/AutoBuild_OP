#!/bin/bash

# 定义要删除的文件类型列表
file_types=("config.buildinfo" "feeds.buildinfo" "*.manifest" "*-kernel.bin" "*-squashfs-combined.vmdk" "*-rootfs.*" "profiles.json" "sha256sums" "version.buildinfo" "*.itb" )

# 定义要处理的目录路径
dir_path="./"

# 遍历文件类型列表，删除匹配的文件
for file_type in "${file_types[@]}"; do
    find "$dir_path" -type f -name "$file_type" -exec rm -rf {} \;
done

# 输出完成信息
echo "Files have been deleted!"