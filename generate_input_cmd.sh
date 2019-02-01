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
read -p "please input command: "
(
cat << EOF
$REPLY
EOF
) > ${CMDS_LIST}
while true
do
	read -p "Please enter whether multiple processes are running backstage[y/n]: "
	bg=$REPLY
	if [[ $bg = "y" ]] || [[ $bg = "n" ]];then
		break
	fi
done
sh exec_morelist.sh ${CONF_LIST} ${CMDS_LIST} $bg
rm /tmp/*.$$
