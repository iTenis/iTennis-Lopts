#!/bin/sh
source_functions()
{
        . conf/itennis.conf
        . scripts/log_print
        . scripts/exec_remote
}
source_functions
CMDS_LIST=/tmp/cmds_list.$$
CONF_LIST=${HOSTS_CONF}
(
cat << EOF
ls /tmp
df -h
free -g
cat /etc/ssh/sshd_config  | grep "PermitTTY yes"
cat /etc/ssh/sshd_config  | grep "PermitTTY no" | awk '{print \$3}'
EOF
) > ${CMDS_LIST}

sh exec_list.sh ${CONF_LIST} ${CMDS_LIST}
rm /tmp/*.$$
