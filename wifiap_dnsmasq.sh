#!/bin/sh
set -e

if [ "$#" -lt "1" ] ; then
        echo "Usage: $0 network_interface" >&2
        exit 1
fi

iface="$1"

ipnetwork=172.18.3.0
ipmasklen=24

###
# this is pretty crude, but works
###
ipaddr=${ipnetwork%.0}.1
dhcp_first=${ipnetwork%.0}.224
dhcp_last=${ipnetwork%.0}.254

ip addr flush dev $iface
ip addr add $ipaddr/$ipmasklen dev $iface

# get default route interface
def_if="$(ip route show default |  awk 'match($0,/dev (\w+)/,a){ print a[1] }')"
if [ -z "$def_if" ] ; then
        echo "$0 WTF?! No default route found." >&2
        exit 1
fi

echo "Default route goes out on interface $def_if."

iptables -t nat -F POSTROUTING
iptables -t nat -I POSTROUTING -o "$def_if" -s $ipnetwork/$ipmasklen -j MASQUERADE
sysctl net.ipv4.conf.all.forwarding=1 net.ipv4.conf.default.forwarding=1 

exec dnsmasq -k -i $iface -z -F $dhcp_first,$dhcp_last
