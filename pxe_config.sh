#!/bin/bash

source conf/itennis.conf
source scripts/log_print
source scripts/network_config
source scripts/packets_install

log INFO "----------------Start check your configuration----------------"
echo $SERVER_IP &> /dev/null 		&& log WARN  "server ip		:$SERVER_IP" 
echo $SERVER_NETMASK &> /dev/null 	&& log WARN  "server netmask	:$SERVER_NETMASK" 
echo $BIND_INTERFACE &> /dev/null 	&& log WARN  "server interface	:$BIND_INTERFACE" 
echo $DHCP_START_ADDRESS &> /dev/null 	&& log WARN  "DHCP start addr	:$DHCP_START_ADDRESS" 
echo $DHCP_END_ADDRESS &> /dev/null 	&& log WARN  "DHCP end address	:$DHCP_END_ADDRESS" 
echo $INSTALL_OS &> /dev/null 		&& log WARN  "Batch install os	:${INSTALL_OS}${OS_VERSION}" 
log WARN  "System iso file	:`ls from_iso/*.iso`"
echo $ROOT_PWD &> /dev/null 		&& log WARN  "Batch install pwd	:$ROOT_PWD"
log INFO "----------------End check your configuration----------------"

isContinue='y'
function isNext()
{
        read -p 'Confirm whether to continue?[y/n]' isContinue
        if [ "$isContinue" = "n" ];then
                exit 1
        elif [ "$isContinue" = "y" ];then
                return 0
        else
                isNext
        fi
}


isNext

#配置网络接口
#inetwork $BIND_INTERFACE $SERVER_IP $SERVER_NETMASK
#if [ $? == 0 ];then
#	log INFO  "Interface $BIND_INTERFACE configuration success"
#else
#	log ERROR  "Interface $BIND_INTERFACE configuration failed"
#	exit
#fi

#配置YUM本地仓库源
sh scripts/yum_config
if [ $? == 0 ];then
        log INFO  "Yum configuration success"
else
        log ERROR  "Yum configuration failed"
        exit
fi


#补全需要的补丁包
i_packets

log INFO "NOTE:Initial environment configuration completed."
isNext

#配置网络接口
inetwork $BIND_INTERFACE $SERVER_IP $SERVER_NETMASK
if [ $? == 0 ];then
        log INFO  "Interface $BIND_INTERFACE configuration success"
else
        log ERROR  "Interface $BIND_INTERFACE configuration failed"
        exit
fi

sed -i '/disable/s/yes/no/' /etc/xinetd.d/tftp

cp -rvf /etc/dhcp/dhcpd.conf /tmp/dhcpd.conf.bak
(
cat << EOF
option space PXE;
option PXE.mtftp-ip    code 1 = ip-address;
option PXE.mtftp-cport code 2 = unsigned integer 16;
option PXE.mtftp-sport code 3 = unsigned integer 16;
option PXE.mtftp-tmout code 4 = unsigned integer 8;
option PXE.mtftp-delay code 5 = unsigned integer 8;
option client-system-arch code 93 = unsigned integer 16;
#option domain-name-servers 8.8.8.8, $SERVER_IP;
allow booting;
allow bootp;
default-lease-time 600;
max-lease-time 7200;
#ddns-update-style interim;
subnet $DHCP_SUBNET netmask $SERVER_NETMASK {
  range $DHCP_START_ADDRESS $DHCP_END_ADDRESS;
  option routers $SERVER_IP;
 class "pxeclients" {
        match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";
        next-server $SERVER_IP;
        if option client-system-arch = 00:07 or option client-system-arch = 00:09 {
         filename "uefi/shim.efi";
         #filename "efi/BOOTX64.efi";
        } else {
         filename "pxelinux/pxelinux.0";
        }
   }
}
EOF
) > /etc/dhcp/dhcpd.conf


mkdir -p /var/lib/tftpboot/pxelinux/pxelinux.cfg
mkdir -p /var/lib/tftpboot/uefi
mkdir -p /var/www/html/{kickstarts,os}
<<!
for osdir in $SUPPORT_OS;do
	for osversion in $SUPPORT_VERSION;do
		mkdir -p /var/www/html/os/$osdir/$osversion
		mkdir -p /var/lib/tftpboot/images/$osdir/$osversion
	done
done
!
mkdir -p /var/www/html/os/$INSTALL_OS/$OS_VERSION
mkdir -p /var/lib/tftpboot/images/$INSTALL_OS/$OS_VERSION

#mkdir -p $TMPDIR
#cp -r pub/Packages/syslinux-4.05-13.el7.x86_64.rpm $TMPDIR
#cp -r pub/Packages/shim-x64-12-1.el7.centos.x86_64.rpm $TMPDIR
#cp -r pub/Packages/grub2-efi-x64-2.02-0.65.el7.centos.2.x86_64.rpm $TMPDIR
#cd $TMPDIR
#rpm2cpio $TMPDIR/syslinux-4.05-13.el7.x86_64.rpm |cpio -dimv
#rpm2cpio $TMPDIR/shim-x64-12-1.el7.centos.x86_64.rpm |cpio -dimv
#rpm2cpio $TMPDIR/grub2-efi-x64-2.02-0.65.el7.centos.2.x86_64.rpm |cpio -dimv
#cd -
#cp ./usr/share/syslinux/{pxelinux.0,vesamenu.c32,memdisk} /var/lib/tftpboot/pxelinux
#cp ./usr/share/syslinux/memdisk /var/lib/tftpboot/uefi
#cp ./boot/efi/EFI/centos/shim.efi /var/lib/tftpboot/uefi
#cp ./boot/efi/EFI/centos/grubx64.efi /var/lib/tftpboot/uefi


#cp -rvf pub/isolinux/{initrd.img,vmlinuz} /var/lib/tftpboot/pxelinux/centos7.4/

#set bios boot
#cp -rvf syslinux-6.03/bios/com32/elflink/ldlinux/ldlinux.c32 /var/lib/tftpboot/pxelinux/
#cp -rvf syslinux-6.03/com32/menu/vesamenu.c32 /var/lib/tftpboot/pxelinux/
#cp -rvf syslinux-6.03/core/pxelinux.0 /var/lib/tftpboot/pxelinux/
#cp -rvf syslinux-6.03/memdisk/memdisk /var/lib/tftpboot/pxelinux/
#cp -rvf syslinux-6.03/bios/com32/lib/libcom32.c32 /var/lib/tftpboot/pxelinux/
#cp -rvf syslinux-6.03/bios/com32/libutil/libutil.c32 /var/lib/tftpboot/pxelinux/

cp -rvf boot/pxelinux /var/lib/tftpboot/
cp -rvf boot/uefi /var/lib/tftpboot/
cp -rvf boot/efi /var/lib/tftpboot/
#cp -rvf boot/images /var/lib/tftpboot/
cp -rvf boot/kickstarts /var/www/html/

sh make_kickstart_files $SERVER_IP $INSTALL_OS ${OS_VERSION} $ROOT_PWD /var/www/html/kickstarts/${INSTALL_OS}_${OS_VERSION}_ks.cfg
sh make_biosdefault_files $SERVER_IP $INSTALL_OS ${OS_VERSION} $INSTALL_INTERFACE
sh make_uefigrub_files $SERVER_IP $INSTALL_OS ${OS_VERSION} $INSTALL_INTERFACE
sh make_efidefault_files $SERVER_IP $INSTALL_OS ${OS_VERSION} $INSTALL_INTERFACE

log INFO "check need to install os file"
if [ `ls -A to_iso/*.iso | wc -w` == 0 ];then
	echo "**************************************************"
	ls from_iso/*.iso
	echo "**************************************************"
	isNext
	umount /var/www/html/os/$INSTALL_OS/${OS_VERSION};
	mount -o loop from_iso/*.iso /var/www/html/os/$INSTALL_OS/${OS_VERSION}; 
else
	echo "**************************************************"
	ls to_iso/*.iso
	echo "**************************************************"
	isNext
	umount /var/www/html/os/$INSTALL_OS/${OS_VERSION};
	mount -o loop to_iso/*.iso /var/www/html/os/$INSTALL_OS/${OS_VERSION}; 
fi

cp -rvf /var/www/html/os/$INSTALL_OS/${OS_VERSION}/isolinux/{initrd.img,vmlinuz} /var/lib/tftpboot/images/$INSTALL_OS/$OS_VERSION
if [ $? == 0 ];then
	log INFO "system images is ready success" 
else
	log ERROR "system images is ready failed, please check you os's initrd.img,vmlinuz"
	exit
fi

sed -i "s/SELINUX=.*$/SELINUX=disabled/" /etc/selinux/config
setenforce 0

if [ `echo $OS_VERSION | awk -F '.' '{print $1}'` == 7 ] ;then
	#ifirewall-cmd --add-service=tftp --permanent &> /dev/null
	#log INFO "firewall allow tftp service success"
	#firewall-cmd --add-service=dhcp --permanent &> /dev/null
	#log INFO "firewall allow dhcp service success"
	#firewall-cmd --add-service=http --permanent &> /dev/null
	#log INFO "firewall allow http service success"
	#firewall-cmd --add-service=xinetd --permanent &> /dev/null
	#log INFO "firewall allow xinetd service success"
	sed -i "s/efi\/BOOTX64.efi/uefi\/shim.efi/g" /etc/dhcp/dhcpd.conf
	sed -i "s/#%addon/%addon/g" /var/www/html/kickstarts/${INSTALL_OS}_${OS_VERSION}_ks.cfg
	sed -i "s/#%end/%end/g" /var/www/html/kickstarts/${INSTALL_OS}_${OS_VERSION}_ks.cfg
	service firewalld stop
	chkconfig firewalld off
	log INFO "Firewall closed successfully"

	#systemctl enable dhcpd tftp xinetd httpd
	#log INFO "allow service tftp,dhcp,xinetd and http boot enabled"
	#systemctl restart dhcpd tftp xinetd httpd
	#log INFO "started service tftp,dhcp,xinetd and http success"
else
	sed -i "s/uefi\/shim.efi/efi\/BOOTX64.efi/g" /etc/dhcp/dhcpd.conf
	service iptables stop
	chkconfig iptables off
	log INFO "Iptables closed successfully"
fi

service network restart
if [ $? == 0 ];then
	log INFO "network restart success"
else
	log ERROR "network restart failed"
fi

chkconfig tftp on &> /dev/null
service tftp restart &> /dev/null
log INFO "allow service tftp boot enabled and start"
chkconfig dhcpd on &> /dev/null
service dhcpd restart &> /dev/null
log INFO "allow service dhcp boot enabled and start"
chkconfig xinetd on &> /dev/null
service xinetd restart &> /dev/null
log INFO "allow service xinetd boot enabled and start"
chkconfig httpd on &> /dev/null
service httpd restart &> /dev/null
log INFO "allow service http boot enabled and start"
