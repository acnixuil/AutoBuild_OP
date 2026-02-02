#!/bin/sh

mkdir -p /etc/tailscale
touch /etc/config/tailscale

uci -q batch <<EOF
set tailscale.settings=tailscale
set tailscale.settings.port='61422'
set tailscale.settings.state_file='/etc/tailscale/tailscaled.state'
set tailscale.settings.fw_mode='nftables'
set tailscale.settings.log_stderr='1'
set tailscale.settings.log_stdout='1'
commit tailscale
EOF

cat <<EOT > /etc/firewall.user
#!/bin/sh
nft insert rule inet fw4 output meta nfproto ipv6 udp sport 61422 counter drop
nft insert rule inet fw4 input meta nfproto ipv6 udp dport 61422 counter drop
EOT
chmod +x /etc/firewall.user

uci -q delete firewall.custom_user_script
uci set firewall.custom_user_script=include
uci set firewall.custom_user_script.path='/etc/firewall.user'
uci set firewall.custom_user_script.type='script'
uci set firewall.custom_user_script.fw4_compatible='1'

if ! uci show network | grep -q "network.tailscale="; then
    uci set network.tailscale='interface'
    uci set network.tailscale.proto='none'
    uci set network.tailscale.device='tailscale0'
    uci commit network
fi

if ! uci show firewall | grep -q "name='tailscale'"; then
    uci add firewall zone
    uci set firewall.@zone[-1].name='tailscale'
    uci set firewall.@zone[-1].input='ACCEPT'
    uci set firewall.@zone[-1].output='ACCEPT'
    uci set firewall.@zone[-1].forward='ACCEPT'
    uci set firewall.@zone[-1].masq='1'
    uci set firewall.@zone[-1].mtu_fix='1'
    uci add_list firewall.@zone[-1].network='tailscale'

    uci add firewall forwarding
    uci set firewall.@forwarding[-1].src='lan'
    uci set firewall.@forwarding[-1].dest='tailscale'

    uci add firewall forwarding
    uci set firewall.@forwarding[-1].src='tailscale'
    uci set firewall.@forwarding[-1].dest='lan'
    
    uci commit firewall
fi

uci commit firewall
/etc/init.d/network reload
/etc/init.d/firewall restart

/etc/init.d/tailscale enable
/etc/init.d/tailscale start

exit 0