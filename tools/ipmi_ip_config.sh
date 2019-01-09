#!/bin/bash
yum install -y ipmitool
modprobe ipmi_watchdog
modprobe ipmi_poweroff
modprobe ipmi_devintf
modprobe ipmi_si
ipmitool chassis power status
ipmitool lan set 1 ipaddr $1
ipmitool lan set 1 netmask $2
ipmitool lan set 1 defgw ipaddr $3
