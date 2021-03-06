#!/bin/bash
###########################
#将XFS格式的逻辑卷分区的home目录删掉，将剩余空间全部分给根分区
###########################
TYPE=centos
DE_PART=root

umount /home
lvremove -f /dev/${TYPE}/home
sed -i  "/home/d" /etc/fstab

echo "y" | lvcreate -L +10G -n tmp ${TYPE}
echo "y" | mkfs.xfs /dev/${TYPE}/tmp
echo "/dev/mapper/${TYPE}-tmp /tmp xfs defaults 0 0" >> /etc/fstab 
mount /dev/mapper/${TYPE}-tmp

cp -ar /var /var_bak
echo "y" | lvcreate -L +10G -n var ${TYPE}
echo "y" | mkfs.xfs /dev/${TYPE}/var
echo "/dev/mapper/${TYPE}-var /var xfs defaults 0 0" >> /etc/fstab
mount /dev/mapper/${TYPE}-var
cp -ar /var_bak/* /var
#rm -rf /var_bak

echo "y" | lvcreate -L +150G -n log ${TYPE}
echo "y" | mkfs.xfs /dev/${TYPE}/log
echo "/dev/mapper/${TYPE}-log /var/log xfs defaults 0 0" >> /etc/fstab
mkdir -p /var/log
mount /dev/mapper/${TYPE}-log

echo "y" | lvcreate -L +60G -n bigdata ${TYPE}
echo "y" | mkfs.xfs /dev/${TYPE}/bigdata
echo "/dev/mapper/${TYPE}-bigdata /srv/BigData xfs defaults 0 0" >> /etc/fstab    
mkdir -p /srv/BigData
mount /dev/mapper/${TYPE}-bigdata

echo "y" | lvcreate -L +60G -n opt ${TYPE}
echo "y" | mkfs.xfs /dev/${TYPE}/opt
echo "/dev/mapper/${TYPE}-opt /opt xfs defaults 0 0" >> /etc/fstab
mount /dev/mapper/${TYPE}-opt

echo "y" | lvextend -l +100%FREE /dev/mapper/${TYPE}-opt
echo "y" | xfs_growfs /dev/mapper/${TYPE}-opt
