# firewall custom
echo "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> package/network/config/firewall/files/firewall.user
#echo "iptables -t nat -I POSTROUTING -j FULLCONENAT" >> package/network/config/firewall/files/firewall.user
# Modify default IP
sed -i 's/192.168.1.1/192.168.2.254/g' package/base-files/files/bin/config_generate
#sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/base-files/files/etc/shadow
#sed -i "/CYXluq4wUazHjmCDBCqXF/d" package/lean/default-settings/files/zzz-default-settings