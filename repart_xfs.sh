#!/bin/bash
###########################
#将XFS格式的逻辑卷分区的home目录删掉，将剩余空间全部分给根分区
###########################
TYPE=rhel
UM_PART=home
DE_PART=root

umount /${UM_PART}
lvremove -f /dev/${TYPE}/${UM_PART}
#echo "y" | lvcreate -L +4G -n ${UM_PART} ${TYPE}
#mkfs.xfs /dev/${TYPE}/${UM_PART}
#mount -a
sed -i  "/home/d" /etc/fstab
lvextend -l +100%FREE /dev/mapper/${TYPE}-${DE_PART}
xfs_growfs /dev/mapper/${TYPE}-${DE_PART}
mount -a
