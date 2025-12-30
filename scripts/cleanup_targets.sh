#!/bin/bash

dir_path="./"
keep_patterns=(
    "*-squashfs-factory.bin"
    "*-squashfs-sysupgrade.bin"
    "*-squashfs-combined.img.gz"
    "*-squashfs-combined.vmdk"
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