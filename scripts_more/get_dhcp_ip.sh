#!/bin/bash

source conf/itennis.conf
source scripts/log_print

for i in `grep -v "^#" /var/lib/dhcpd/dhcpd.leases | grep lease | awk '{print $2}'|sort -u | uniq`
do
(
	ping -c 1 -w 2 $i &> /dev/null
	if [ $? = 0 ];then
		log INFO "ping $i success"
	else
		log ERROR "ping $i failed"
	fi
) &
done
wait
log INFO "Get dhcp ip address success"
