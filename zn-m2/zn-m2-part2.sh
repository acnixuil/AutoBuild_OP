# Modify default IP
sed -i 's/192.168.1.1/192.168.2.1/g' package/base-files/files/bin/config_generate

# 配置alist3编译环境
#rm -rf feeds/packages/lang/golang
#svn export https://github.com/sbwml/packages_lang_golang/branches/19.x feeds/packages/lang/golang