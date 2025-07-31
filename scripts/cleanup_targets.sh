#!/bin/bash

# file_types=("config.buildinfo" "feeds.buildinfo" "*.manifest" "*-kernel.bin" "*-squashfs-combined.vmdk" "*-rootfs.*" "profiles.json" "sha256sums" "version.buildinfo" "*.itb")
#
# dir_path="./"
#
# if [ -d "${dir_path}packages" ]; then
#     rm -rf "${dir_path}packages"
#     echo "packages directory has been deleted!"
# fi
#
# for file_type in "${file_types[@]}"; do
#     find "$dir_path" -type f -name "$file_type" -exec rm -rf {} \;
# done
#
# !/bin/bash

dir_path="./"
keep_patterns=(
    "*-squashfs-factory.bin"
    "*-squashfs-sysupgrade.bin"
    "*-squashfs-combined-efi.img.gz"
    "*-squashfs-combined-efi.vmdk"
    "*-squashfs-sysupgrade.itb"
    "*-squashfs-factory.ubi"
    "*packages.tar.gz"
)

[ -d "${dir_path}packages" ] && rm -rf "${dir_path}packages" && echo "packages directory has been deleted!"

find "$dir_path" -type f | while read -r file; do
    keep=false
    for pattern in "${keep_patterns[@]}"; do
        [[ "$(basename "$file")" == $pattern ]] && keep=true && break
    done
    $keep || rm -f "$file"
done