#!/bin/bash
rpm -ivh /tmp/itennis_tmp/megacli/Lib_Utils-1.00-09.noarch.rpm
rpm -ivh /tmp/itennis_tmp/megacli/MegaCli-8.07.10-1.noarch.rpm
adapter=`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL | grep Adapter | awk -F '#' '{print $2}'`
arraid=(`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aAll| grep -Ei "(Enclosure Device|Slot Number)"|awk -F ':' '{print $2}'`)
length=${#arraid[@]}
disknum=$1
raidmode=$2
raidinfo=""
mkdir -p /opt/raidconf
mv /opt/raidconf/* /tmp &> /dev/null
for (( i=4;i<$length;i++ ))
do
	((tmp=$i+$disknum*2-1))
	flag=0
	for j in `seq $i 2 $tmp`	
	do
		if [ "${arraid[$j]}" = "" ];then break;fi
		raidinfo=$raidinfo,`echo -ne ${arraid[$j]}:${arraid[$j+1]}`
		((flag=$flag+1))
	done
	if [[ $flag = $disknum ]];then
		#echo /opt/MegaRAID/MegaCli/MegaCli64 -CfgLdADD -r${raidmode} [${raidinfo:1}] WB Direct -a${adapter};
		/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdADD -r${raidmode} [${raidinfo:1}] WB Direct -a${adapter}
	fi
	raidinfo=""
	((i=$i+2*$disknum-1))
done
