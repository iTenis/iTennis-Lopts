#!/bin/bash
#Description:Team的绑定效果包含所有bond的功能，RHEL7以后的版本，之前在redhat6下使用的bond脚本不太适用，做如下调整使用。

#Author:iTennis
#Version:1.0
#CreateTime:2018-08-10 14:13:58
IP=$3
GATE=$5
NETMASK=$4
ETH1=$6
ETH2=$7
TEARM=$1

nmcli con add type team con-name $TEARM ifname $TEARM config '{"runner": {"name":"activebackup"}}'
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$ETH1
TYPE=Ethernet
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=$ETH1
DEVICE=$ETH1
ONBOOT=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
PEERDNS=yes
PEERROUTES=yes
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$ETH2
TYPE=Ethernet
BOOTPROTO=dhcp
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=$ETH2
DEVICE=$ETH2
ONBOOT=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
PEERDNS=yes
PEERROUTES=yes
EOF
cat << EOF > /etc/sysconfig/network-scripts/ifcfg-$TEARM
DEVICE=$TEARM
TEAM_CONFIG="{"runner": {"name":"activebackup"}}"
DEVICETYPE=Team
BOOTPROTO=static
DEFROUTE=yes
IPV4_FAILURE_FATAL=yes
IPV6INIT=no
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
NAME=$TEARM
ONBOOT=yes
IPV6_PEERDNS=yes
IPV6_PEERROUTES=yes
IPADDR=$IP
NETMASK=$NETMASK
GATEWAY=$GATE
EOF
nmcli connection add type team-slave con-name $TEARM-port1 ifname $ETH1 master $TEARM
nmcli connection add type team-slave con-name $TEARM-port2 ifname $ETH2 master $TEARM
nmcli connection up $TEARM-port2
nmcli connection up $TEARM-port1
#systemctl restart network

#teamdctl $TEARM state
