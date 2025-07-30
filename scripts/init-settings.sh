#!/bin/bash

# Set default theme to luci-theme-argon
uci set luci.main.mediaurlbase='/luci-static/bootstrap'
uci commit luci

# nikki
uci set nikki.config.start_delay='2'
uci set nikki.proxy.bypass_china_mainland_ip='1'
uci set nikki.proxy.ipv6_proxy='0'
uci set nikki.proxy.proxy_tcp_dport='21 22 80 110 143 194 443 465 853 993 995 8080 8443'
uci set nikki.proxy.proxy_udp_dport='123 443 8443'
uci set nikki.mixin.dns_mode='redir-host'
uci commit nikki

uci set argon.@global[0].mode='dark'
uci set argon.@global[0].online_wallpaper='none'
uci commit argon

uci delete dropbear.main.DirectInterface
uci uci delete dropbear.main.Interface
uci commit dropbear
service dropbear restart

exit 0
