#!/bin/bash
start=`date +'%F %H:%M:%S'`
source_functions()
{
        . conf/itennis.conf
        . scripts/log_print
        . scripts/exec_remote
}
source_functions
tmp_fifofile="/tmp/$.fifo"
CONF_LIST=/tmp/conf_list.$$
RESULT_ALL=/tmp/res_all.$$
SOURCE_FILE=$2
DEST_FILE=$3
mkfifo $tmp_fifofile      # 新建一个fifo类型的文件
exec 6<>$tmp_fifofile      # 将fd6指向fifo类型
rm $tmp_fifofile
grep -v "^#" $1 > ${CONF_LIST}
THREAD=`cat ${CONF_LIST} | wc -l`
for ((i=1;i<$THREAD+1;i++));do 
	echo
done >&6

for ((i=1;i<$THREAD+1;i++))
do
{
	read -u6
	{
		arr=(`sed -n ${i}p $CONF_LIST`)
		echo "[`date`] cp_file_from_r $REMOTE_PORT $REMOTE_TIMEOUT ${arr[0]} ${arr[2]} ${arr[3]} ${SOURCE_FILE} ${DEST_FILE}" | tr -d '\r' >> /var/log/iTennis/${arr[0]}.log
                cp_file_from_r $REMOTE_PORT $REMOTE_TIMEOUT ${arr[0]} ${arr[2]} ${arr[3]} ${SOURCE_FILE} ${DEST_FILE}
		if [[ $? = 0 ]];then
			log WARN "The current ${i} , ${arr[0]} is finshed" >> $RESULT_ALL
		else
			log ERROR "The current ${i} , ${arr[0]} is execute failed , pleace chect it" >> $RESULT_ALL
		fi
	} || {
		log ERROR  "thread error"
	}
	echo >&6
} &
done
wait
exec 6>&-
end=`date +'%F %H:%M:%S'`
log INFO "--------------------------------------------------------------"
sort -n -k 6 $RESULT_ALL
log INFO  "Begin time:$start , End time: $end"
log INFO "--------------------------------------------------------------"
rm /tmp/*.$$
exit 0
