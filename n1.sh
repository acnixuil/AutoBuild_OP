# firewall custom
echo "iptables -t nat -I POSTROUTING -o eth0 -j MASQUERADE" >> package/network/config/firewall/files/firewall.user
# Modify default IP
sed -i 's/192.168.1.1/192.168.2.88/g' package/base-files/files/bin/config_generate