#!/bin/bash

# 获取远程仓库的所有标签
tags=$(git ls-remote --tags origin | awk -F/ '{print $NF}' | sed 's/\^{}//')

# 循环删除每个标签
for tag in $tags
do
  git push origin --delete "$tag"
done