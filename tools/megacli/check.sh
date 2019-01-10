#!/bin/bash
rpm -ivh /tmp/itennis_tmp/megacli/Lib_Utils-1.00-09.noarch.rpm
rpm -ivh /tmp/itennis_tmp/megacli/MegaCli-8.07.10-1.noarch.rpm	
#/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL
adapter=`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL | grep Adapter | awk -F '#' '{print $2}'`
arraid=(`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aAll| grep -Ei "(Enclosure Device|Slot Number)"|awk -F ':' '{print $2}'`)
length=${#arraid[@]}
mv /opt/it_raid0.sh /tmp &> /dev/null
mv /opt/it_raid1.sh /tmp &> /dev/null
for (( i=0;i<$length;i++ ))
do
	echo "/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r0 [${arraid[i]}:${arraid[i+1]}] WB Direct -a${adapter}" >> /opt/it_raid0.sh
	i=$i+1
done
for (( i=0;i<$length;i++ ))
do
	if [[ ${arraid[i+2]} = "" ]];then echo -e "\033[31m[ERROR] There's a disk that doesn't make RAID1 \033[0m";break;fi
        echo "/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r1 [${arraid[i]}:${arraid[i+1]},${arraid[i+2]}:${arraid[i+3]}] WB Direct -a${adapter}" >> /opt/it_raid1.sh
        i=$i+3
done
