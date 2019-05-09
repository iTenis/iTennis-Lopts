#!/bin/bash
interbonddir=/etc/sysconfig/network-scripts
bondethxy=$1
bondethx=$6           #绑定网卡的名称1
bondethy=$7           #绑定网卡的名称2
modeinfo=$2
ipaddr=$3       #绑定接口的ip地址
gateway=$5    #绑定接口的网关
netmask=$4     #绑定接口的子网掩码
if [ ! -f "${interbonddir}/ifcfg-$bondethx" ]; then  echo -e "\033[31m[ERROR]	不存在该网卡:${ipaddr} $bondethx\033[0m";exit; fi
if [ ! -f "${interbonddir}/ifcfg-$bondethy" ]; then  echo -e "\033[31m[ERROR]	不存在该网卡:${ipaddr} $bondethy\033[0m";exit; fi
(
cat << EOF
DEVICE=${bondethxy}
NAME=${bondethxy}
TYPE=Bond
ONBOOT=yes
BOOTPROTO=static
BONDING_MASTER=yes
BONDING_OPTS="mode=${modeinfo} miimon=50 updelay=0 downdelay=0"
IPADDR=$ipaddr
GATEWAY=$gateway
NETMASK=$netmask
EOF
) > ${interbonddir}/ifcfg-${bondethxy}

cp ${interbonddir}/ifcfg-$bondethx /tmp/ifcfg-$bondethx-bak
cp ${interbonddir}/ifcfg-$bondethy /tmp/ifcfg-$bondethy-bak

(
cat << EOF
alias ${bondethxy} bonding
options ${bondethxy} miimon=50  mode=${modeinfo}
EOF
) >> /etc/modprobe.d/dist.conf

sed -i '/^MASTER/d' ${interbonddir}/ifcfg-$bondethx
sed -i '/^SLAVE/d' ${interbonddir}/ifcfg-$bondethx
sed -i '/^BOOTPROTO/d' ${interbonddir}/ifcfg-$bondethx
sed -i '/^ONBOOT/d' ${interbonddir}/ifcfg-$bondethx
sed -i '/^IPADDR/d' ${interbonddir}/ifcfg-$bondethx
sed -i '/^NETMASK/d' ${interbonddir}/ifcfg-$bondethx
sed -i '/^GATEWAY/d' ${interbonddir}/ifcfg-$bondethx

sed -i '/^MASTER/d' ${interbonddir}/ifcfg-$bondethy
sed -i '/^SLAVE/d' ${interbonddir}/ifcfg-$bondethy
sed -i '/^BOOTPROTO/d' ${interbonddir}/ifcfg-$bondethy
sed -i '/^ONBOOT/d' ${interbonddir}/ifcfg-$bondethy
sed -i '/^IPADDR/d' ${interbonddir}/ifcfg-$bondethy
sed -i '/^NETMASK/d' ${interbonddir}/ifcfg-$bondethy
sed -i '/^GATEWAY/d' ${interbonddir}/ifcfg-$bondethy

(
cat << EOF
BOOTPROTO=none
ONBOOT=yes
MASTER=${bondethxy}
SLAVE=yes
EOF
) >> ${interbonddir}/ifcfg-$bondethx

(
cat << EOF
BOOTPROTO=none
ONBOOT=yes
MASTER=${bondethxy}
SLAVE=yes
EOF
) >> ${interbonddir}/ifcfg-$bondethy
