#!/bin/bash

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/bootstrap'
uci commit luci

# nikki
uci set nikki.config.start_delay='2'
uci set nikki.config.scheduled_restart='1'
uci set nikki.proxy.bypass_china_mainland_ip='1'
uci set nikki.proxy.bypass_china_mainland_ip6='1'
# uci set nikki.proxy.ipv6_proxy='0'
uci set nikki.proxy.proxy_tcp_dport='21 22 80 110 143 194 443 465 853 993 995 8080 8443'
uci set nikki.proxy.proxy_udp_dport='123 443 8443'
uci set nikki.mixin.dns_mode='redir-host'
uci set nikki.mixin.tun_stack='system'
uci set nikki.mixin.ui_url='https://github.com/Zephyruso/zashboard/archive/refs/heads/gh-pages-misans-only.zip'
uci commit nikki

# momo
# uci set momo.proxy.bypass_china_mainland_ip='1'
uci set momo.proxy.proxy_tcp_dport='21 22 80 110 143 194 443 465 853 993 995 8080 8443'
uci set momo.proxy.proxy_udp_dport='123 443 8443'
uci commit momo

uci set argon.@global[0].mode='dark'
uci set argon.@global[0].online_wallpaper='none'
uci commit argon

uci delete dropbear.main.DirectInterface
uci delete dropbear.main.Interface
uci commit dropbear
service dropbear restart

# uci set dhcp.@dnsmasq[0].cachesize='8000'
# uci set dhcp.@dnsmasq[0].min_cache_ttl='600'
# uci set dhcp.@dnsmasq[0].max_cache_ttl='86400'
# uci commit dhcp

uci set attendedsysupgrade.client.login_check_for_upgrades='0'
uci commit attendedsysupgrade

grep -q "/etc/lucky/" /etc/sysupgrade.conf || echo "/etc/lucky/" >> /etc/sysupgrade.conf

exit 0
