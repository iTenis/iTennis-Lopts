#!/bin/bash
cd /etc/sysconfig/network-scripts
bondethx=eno16777736	#绑定网卡的名称1
bondethy=eno33554960	#绑定网卡的名称2
ipaddr=192.168.64.131	#绑定接口的ip地址
gateway=192.168.0.34	#绑定接口的网关
prefix=24	#绑定接口的子网掩码

#创建绑定的虚拟网卡信息ifcfg-bond0
function createbond()
{
	echo "DEVICE=bond0" > ./ifcfg-bond0 &
	echo "NAME=bond0" >> ./ifcfg-bond0 &
	echo "TYPE=Bond" >> ./ifcfg-bond0 &
	echo "BONDING_MASTER=yes" >> ./ifcfg-bond0 &
	echo "BONDING_OPTS=\"mode=802.3ad miimon=100 updelay=0 downdelay=0 lacp_rate=fast\"" >> ./ifcfg-bond0 &
	echo "IPADDR=$ipaddr" >> ./ifcfg-bond0 &
	echo "GATEWAY=$gateway" >> ./ifcfg-bond0 &
	echo "PREFIX=$prefix" >> ./ifcfg-bond0 &
	echo "DNS1=114.114.114.114" >> ./ifcfg-bond0 &
	echo "ONBOOT=yes" >> ./ifcfg-bond0 &
	echo "BOOTPROTO=none" >> ./ifcfg-bond0 &
}
cp ifcfg-$bondethx ./ifcfg-$bondethx-bak
cp ifcfg-$bondethy ./ifcfg-$bondethy-bak

if  
	grep  -q "MASTER" ifcfg-$bondethx 
	grep  -q "SLAVE" ifcfg-$bondethx 
then 
	sed -i "s/MASTER.*$/MASTER=bond0/" ifcfg-$bondethx &
	sed -i "s/SLAVE.*$/SLAVE=yes/" ifcfg-$bondethx &
else
	echo "MASTER=bond0" >> ifcfg-$bondethx &
	echo "SLAVE=yes" >> ifcfg-$bondethx &
fi
if  
	grep  -q "MASTER" ifcfg-$bondethy 
	grep  -q "SLAVE" ifcfg-$bondethy 
then 
	sed -i "s/MASTER.*$/MASTER=bond0/" ifcfg-$bondethy &
	sed -i "s/SLAVE.*$/SLAVE=yes/" ifcfg-$bondethy &
else
	echo "MASTER=bond0" >> ifcfg-$bondethy &
	echo "SLAVE=yes" >> ifcfg-$bondethy &
fi
sed -i "s/ONBOOT.*$/ONBOOT=yes/" ifcfg-$bondethx &
sed -i "s/ONBOOT.*$/ONBOOT=yes/" ifcfg-$bondethy &
echo -e "$bondethx and $bondethy have been add \033[32m successfully \033[0m "
if [ ! -e "ifcfg-bond0" ]
then		
	createbond
else
	mv ifcfg-bond0 ./ifcfg-bond0-bak
	createbond
fi
echo -e "bond0 have been create \033[32m successfully \033[0m"
service NetworkManager stop
systemctl stop NetworkManager
service network restart
if [ ! $? ];then
	echo -e "service restart \033[31m failed \033[0m"
else
	echo -e "service restart \033[32m successfully \033[0m"
fi
