#!/bin/bash
rpm -ivh /tmp/itennis_tmp/megacli/Lib_Utils-1.00-09.noarch.rpm
rpm -ivh /tmp/itennis_tmp/megacli/MegaCli-8.07.10-1.noarch.rpm
#/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL
adapter=`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aALL | grep Adapter | awk -F '#' '{print $2}'`
arraid=(`/opt/MegaRAID/MegaCli/MegaCli64 -PDList -aAll| grep -Ei "(Enclosure Device|Slot Number)"|awk -F ':' '{print $2}'`)
length=${#arraid[@]}
mkdir -p /opt/raidconf
mv /opt/raidconf/* /tmp &> /dev/null
for (( i=0;i<$length;i++ ))
do
	echo "/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r0 [${arraid[i]}:${arraid[i+1]}] WB Direct -a${adapter}" >> /opt/raidconf/it_raid0.sh
	i=$i+1
done
for (( i=0;i<$length;i++ ))
do
	if [[ ${arraid[i+2]} = "" ]];then echo -e "\033[31m[ERROR] There's a disk that doesn't make RAID1 \033[0m";break;fi
        echo "/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r1 [${arraid[i]}:${arraid[i+1]},${arraid[i+2]}:${arraid[i+3]}] WB Direct -a${adapter}" >> /opt/raidconf/it_raid1.sh
        i=$i+3
done
for (( i=4;i<$length;i++ ))
do
        if [[ ${arraid[i+2]} = "" || ${arraid[i+4]} = "" ]];then echo -e "\033[31m[ERROR] There's a disk that doesn't make RAID5 with 3 blocks \033[0m";break;fi
        echo "/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r5 [${arraid[i]}:${arraid[i+1]},${arraid[i+2]}:${arraid[i+3]},${arraid[i+4]}:${arraid[i+5]}] WB Direct -a${adapter}" >> /opt/raidconf/it_raid5_3.sh
        i=$i+5
done
for (( i=4;i<$length;i++ ))
do
        if [[ ${arraid[i+2]} = "" || ${arraid[i+4]} = "" || ${arraid[i+6]} = "" ]];then echo -e "\033[31m[ERROR] There's a disk that doesn't make RAID5 with 4 blocks \033[0m";break;fi
        echo "/opt/MegaRAID/MegaCli/MegaCli64 -CfgLdAdd -r5 [${arraid[i]}:${arraid[i+1]},${arraid[i+2]}:${arraid[i+3]},${arraid[i+4]}:${arraid[i+5]},${arraid[i+6]}:${arraid[i+7]}] WB Direct -a${adapter}" >> /opt/raidconf/it_raid5_4.sh
        i=$i+7
done
