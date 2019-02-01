#!/bin/sh
source_functions()
{
        . conf/itennis.conf
        . scripts/log_print
        . scripts/exec_remote
}
source_functions
CONF_LIST=${HOSTS_CONF}
read -p "please input scp origin: "
SOURCE_FILE=$REPLY
read -p "please input  scp destination:"
DEST_FILE=$REPLY

sh exescp_list.sh $CONF_LIST $SOURCE_FILE $DEST_FILE
