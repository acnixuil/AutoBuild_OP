#!/bin/sh

# 启用并启动 Tailscale 服务
/etc/init.d/tailscale enable
/etc/init.d/tailscale start

# 等待 tailscale0 设备创建
sleep 5

# 创建 Unmanaged 的 tailscale 接口
uci set network.tailscale='interface'
uci set network.tailscale.proto='none'
uci set network.tailscale.device='tailscale0'

# 提交接口配置更改
uci commit network
/etc/init.d/network reload

# 创建 tailscale 防火墙区域
uci add firewall zone
uci set firewall.@zone[-1].name='tailscale'
uci set firewall.@zone[-1].input='ACCEPT'
uci set firewall.@zone[-1].output='ACCEPT'
uci set firewall.@zone[-1].forward='ACCEPT'
uci set firewall.@zone[-1].masq='1'
uci set firewall.@zone[-1].mtu_fix='1'
uci add_list firewall.@zone[-1].network='tailscale'

# 设置转发规则：允许 tailscale 与 LAN 区域之间的转发
uci add firewall forwarding
uci set firewall.@forwarding[-1].src='tailscale'
uci set firewall.@forwarding[-1].dest='lan'

uci add firewall forwarding
uci set firewall.@forwarding[-1].src='lan'
uci set firewall.@forwarding[-1].dest='tailscale'

# 提交防火墙配置更改
uci commit firewall
/etc/init.d/firewall restart

echo "Tailscale 接口和防火墙配置完成！"