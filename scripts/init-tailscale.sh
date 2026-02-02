#!/bin/sh

mkdir -p /etc/tailscale

cat > /etc/config/tailscale <<EOF
config tailscale 'settings'
	option log_stderr '1'
	option log_stdout '1'
	option port '61422'
	option state_file '/etc/tailscale/tailscaled.state'
	option fw_mode 'nftables'
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
uci commit firewall

/etc/init.d/network reload
/etc/init.d/firewall restart

/etc/init.d/tailscale enable
# /etc/init.d/tailscale start

exit 0