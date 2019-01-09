#!/bin/bash
interface_t=`ip a | grep $1 | awk '{print $NF}'`
sed -i '/^BOOTPROTO/d' /etc/sysconfig/network-scripts/ifcfg-$interface_t
sed -i '/^ONBOOT/d' /etc/sysconfig/network-scripts/ifcfg-$interface_t
sed -i '/^IPADDR/d' /etc/sysconfig/network-scripts/ifcfg-$interface_t
sed -i '/^NETMASK/d' /etc/sysconfig/network-scripts/ifcfg-$interface_t
sed -i '/^GATEWAY/d' /etc/sysconfig/network-scripts/ifcfg-$interface_t
	
(
cat << EOF
BOOTPROTO=static
ONBOOT=yes
IPADDR=$2
NETMASK=$3
GATEWAY=$4
EOF
) >> /etc/sysconfig/network-scripts/ifcfg-$interface_t
