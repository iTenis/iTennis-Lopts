# iTennis-Lopt

## 1、功能列表

| 功能选项：功能名称                  | 使用场景说明                                                 |
| ----------------------------------- | ------------------------------------------------------------ |
| [1]：配置PXE环境(bios/uefi)         | 自动化安装（Redhat和Centos）操作系统                         |
| [2]：更换PXE批量安装的服务器        | 更换现有PXE批量安装的操作系统环境                            |
| [3]：批量修改文件内容               | 修改、替换和删除内容（包括配置文件中的值或任意文本）         |
| [4]：批量双网卡绑定Bond模式配置     | 可以做多组Bond模式的双网卡绑定                               |
| [5]：批量双网卡绑定Team模式配置     | 可以做多组Team模式的双网卡绑定                               |
| [6]：收集LLD配置信息,检查网络连通性 | 可以测试网络连通性，收集cpucore、内存、磁盘数、和磁盘大小的信息 |
| [7]：批量拷贝文件                   | 将本地文件拷贝所有服务器                                     |
| [8]：批量执行命令                   | 在所有服务器上执行命令                                       |
| [9]：批量拷贝文件到本地             | 将所有服务器上的莫个文件拷贝到本地服务器上，作为收集信息功能。 |
| [a]：解决SSH慢的问题                | 主要解决SSH连接缓慢的问题                                    |
| [b]：时区和时间配置                 | 同步配置所有服务器时间和时区                                 |
| [c]：本地Yum仓库源配置              | 配置本地服务器的Yum仓库                                      |
| [d]：批量配置YUM源                  | 配置所有服务器的Yum仓库                                      |
| [e]：批量更换IP地址                 | 可以更换旧IP地址为新IP地址                                   |
| [f]：批量配置RAID                   | 可以批量配置RAID0和RAID1                                     |
| [g]：批量配置BMC地址                | 可以批量配置所有服务器的BMC地址                              |
| [h]：解决重装操作系统无法引导       | 解决二次安装操作系统无法引导问题。                           |
| [i]：本机免密钥通信                 | 本机免密钥访问其他机器                                       |
| [j]：单机配置Bond双网卡绑定         | 单机配置Bond网卡                                             |
| [q]：退出                           | 退出脚本                                                     |
| [r]：重启                           | 重启本地服务器                                               |



## 2、推荐流程

- 暂无



## 3、使用介绍

### 3.1、功能选项【1】：配置PXE环境

1）主要集成了redhat和centos两种操作系统的批量安装操作系统的方法，集成的版本列表如下：

| 操作系统       | 版本 |
| -------------- | ---- |
| centos、redhat | 6.6  |
| centos、redhat | 6.7  |
| centos、redhat | 6.8  |
| centos、redhat | 6.9  |
| centos、redhat | 7.0  |
| centos、redhat | 7.1  |
| centos、redhat | 7.2  |
| centos、redhat | 7.3  |
| centos、redhat | 7.4  |
| centos、redhat | 7.5  |
| centos、redhat | 7.6  |

2）PXE的配置文件

​	PXE相关的配置项主要在conf/itennis.conf和conf/partitions.conf两个文件中，首先介绍一下主配置文件itennis.conf相关的配置项：

```shell
conf/itennis.conf配置说明

#PXE配置参数
SERVER_IP=10.9.9.9					#pxe服务器地址（dhcp，tftp）
SERVER_NETMASK=255.0.0.0			#pxe服务器的掩码
BIND_INTERFACE=eth1					#IP地址配置在eth1的网卡上
DHCP_SUBNET=10.0.0.0				#DHCP服务器的子网
DHCP_START_ADDRESS=10.0.0.1			#DHCP服务器分发的起始地址
DHCP_END_ADDRESS=10.0.250.250		#DHCP服务器分发的结束地址

#批量安装的操作系统信息配置
SUPPORT_OS="centos redhat"			#支持的操作系统类型
SUPPORT_VERSION="6.6 6.7 6.8 6.9 7.0 7.1 7.2 7.3 7.4 7.5 7.6"	#支持的操作系统版本
INSTALL_OS=redhat					#安装的操作系统类型
OS_VERSION=6.6						#安装的操作系统版本
ROOT_PWD=123456						#安装的操作系统ROOT密码
INSTALL_INTERFACE=eth0				#批量安装操作系统使用eth0作为获取地址的网卡

TMPDIR="/tmp/itennis_tmp"			#后续操作的临时目录

#远程执行命令和拷贝文件参数
REMOTE_TIMEOUT=5					#批量执行脚本超时时间
REMOTE_PORT=22						#批量执行脚本的SSH端口号
```

```shell
conf/partitions.conf配置说明

挂载目录		分区格式	分区大小
/boot/efi		efi		300				（建议不要改动，默认添加）

/				ext4	30720
/tmp			ext4	10240
/var			ext4	10240
/var/log		ext4	102400
/srv/BigData	ext4	61440
/opt			ext4	1				（分区大小为“1”不要改动，最后一栏默认为给剩余空间）
```

以上是关于两个文件的全部说明，如果作为批量安装，一般只要修改如下值即可

| 参数              | 说明             | 可选 |
| ----------------- | ---------------- | ---- |
| INSTALL_OS        | 操作系统类型     | 可选 |
| OS_VERSION        | 操作系统版本     | 可选 |
| INSTALL_INTERFACE | 接口名称         | 必选 |
| ROOT_PWD          | 密码             | 可选 |
| INSTALL_INTERFACE | 获取DHCP地址接口 | 必选 |
| partitions.conf   | 分区             | 必选 |

3）使用方法

```shell
a、修改配置文件（如上）
b、上传母机的操作系统（PXE操作系统）镜像到from_iso下，如果需要批量安装的操作系统版本和此PXE的操作系统一致，则不需要再次上传到to_iso文件，如果不一致，上传对应的操作系统镜像放到to_iso文件夹下。
c、执行启动脚本，选择功能选项：1，按照操作提示执行，完成接下来的安装。如果出现ERROR，查看相应日志解决处理即可。效果如下：
[root@localhost iTennis-Lopt]# ./start_itennis.sh 
****************************************Please Input***********************************
**  [1]：配置PXE环境                      **  [a]：解决SSH慢的问题                   **
**  [2]：更换PXE批量安装的服务器          **  [b]：时区和时间配置                    **
**  [3]：批量修改文件内容                 **  [c]：本地Yum仓库源配置                 **
**  [4]：批量双网卡绑定Bond模式配置       **  [d]：批量配置YUM源                     **
**  [5]：批量双网卡绑定Team模式配置       **  [e]：批量更换IP地址                    **
**  [6]：收集LLD配置信息,检查网络连通性   **  [f]：批量配置RAID                      **
**  [7]：批量拷贝文件                     **  [g]：批量配置BMC地址                   **
**  [8]：批量执行命令                     **  [h]：解决重装操作系统无法引导          **
**  [9]：批量拷贝文件到本地               **  [i]：本机免密钥通信                    **
**  [q]：退出                             **  [j]：单机配置Bond双网卡绑定            **
**  [r]：重启                             **  [r]：重启                              **
***************************************************************************************
Please input [0-9,a-j,q,r]: 1
配置PXE环境
[INFO]	2019-01-07 17:49:57 ----------------Start check your configuration---------------- (script:config_pxe.sh function: main line:8)
[WARN]	2019-01-07 17:49:57 server ip		:10.9.9.9 (script:config_pxe.sh function: main line:9)
[WARN]	2019-01-07 17:49:58 server netmask	:255.0.0.0 (script:config_pxe.sh function: main line:10)
[WARN]	2019-01-07 17:49:58 server interface	:ens34 (script:config_pxe.sh function: main line:11)
[WARN]	2019-01-07 17:49:58 DHCP start addr	:10.0.0.1 (script:config_pxe.sh function: main line:12)
[WARN]	2019-01-07 17:49:58 DHCP end address	:10.0.250.250 (script:config_pxe.sh function: main line:13)
[WARN]	2019-01-07 17:49:58 Batch install os	:redhat6.6 (script:config_pxe.sh function: main line:14)
[WARN]	2019-01-07 17:49:58 Batch install pwd	:123456 (script:config_pxe.sh function: main line:15)
[INFO]	2019-01-07 17:49:58 ----------------End check your configuration---------------- (script:config_pxe.sh function: main line:16)
Confirm whether to continue?[y/n]y
‘/etc/sysconfig/network-scripts/ifcfg-ens34’ -> ‘/tmp/ifcfg-ens34-bak’
[INFO]	2019-01-07 17:49:59 Interface ens34 configuration success (script:config_pxe.sh function: main line:32)
umount: /media: not mounted
mount: /dev/loop0 is write-protected, mounting read-only
[INFO]	2019-01-07 17:49:59 mount system iso configuration success (script:config_pxe.sh function: main line:42)
mkdir: cannot create directory ‘/etc/yum.repos.d/bak’: File exists
[INFO]	2019-01-07 17:50:06 yum install tftp-server Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:07 yum install dhcp Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:08 yum install xinetd Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:12 yum install httpd Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:25 yum install redhat-lsb Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:27 yum install expect Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:29 yum install syslinux Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:30 yum install tree Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:31 yum install vsftpd Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:33 yum install ipmitool Successful (script:config_pxe.sh function: i_packets main line:6)
[INFO]	2019-01-07 17:50:33 yum install expect Successful (script:config_pxe.sh function: i_packets main line:6)
‘/etc/dhcp/dhcpd.conf’ -> ‘/tmp/dhcpd.conf.bak’
‘boot/pxelinux/menu.c32’ -> ‘/var/lib/tftpboot/pxelinux/menu.c32’
‘boot/pxelinux/pxelinux.0’ -> ‘/var/lib/tftpboot/pxelinux/pxelinux.0’
‘boot/pxelinux/pxelinux.cfg/default’ -> ‘/var/lib/tftpboot/pxelinux/pxelinux.cfg/default’
‘boot/uefi/grub.cfg’ -> ‘/var/lib/tftpboot/uefi/grub.cfg’
‘boot/uefi/grubx64.efi’ -> ‘/var/lib/tftpboot/uefi/grubx64.efi’
‘boot/uefi/memdisk’ -> ‘/var/lib/tftpboot/uefi/memdisk’
‘boot/uefi/shim.efi’ -> ‘/var/lib/tftpboot/uefi/shim.efi’
‘boot/efi’ -> ‘/var/lib/tftpboot/efi’
‘boot/efi/BOOTX64.conf’ -> ‘/var/lib/tftpboot/efi/BOOTX64.conf’
‘boot/efi/BOOTX64.efi’ -> ‘/var/lib/tftpboot/efi/BOOTX64.efi’
‘boot/efi/efidefault’ -> ‘/var/lib/tftpboot/efi/efidefault’
‘boot/efi/splash.xpm.gz’ -> ‘/var/lib/tftpboot/efi/splash.xpm.gz’
‘boot/images/centos/6.6/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/6.6/initrd.img’
‘boot/images/centos/6.6/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/6.6/vmlinuz’
‘boot/images/centos/6.7/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/6.7/initrd.img’
‘boot/images/centos/6.7/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/6.7/vmlinuz’
‘boot/images/centos/6.8/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/6.8/initrd.img’
‘boot/images/centos/6.8/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/6.8/vmlinuz’
‘boot/images/centos/6.9/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/6.9/initrd.img’
‘boot/images/centos/6.9/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/6.9/vmlinuz’
‘boot/images/centos/7.0/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/7.0/initrd.img’
‘boot/images/centos/7.0/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/7.0/vmlinuz’
‘boot/images/centos/7.1/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/7.1/initrd.img’
‘boot/images/centos/7.1/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/7.1/vmlinuz’
‘boot/images/centos/7.2/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/7.2/initrd.img’
‘boot/images/centos/7.2/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/7.2/vmlinuz’
‘boot/images/centos/7.3/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/7.3/initrd.img’
‘boot/images/centos/7.3/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/7.3/vmlinuz’
‘boot/images/centos/7.4/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/7.4/initrd.img’
‘boot/images/centos/7.4/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/7.4/vmlinuz’
‘boot/images/centos/7.5/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/7.5/initrd.img’
‘boot/images/centos/7.5/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/7.5/vmlinuz’
‘boot/images/centos/7.6/initrd.img’ -> ‘/var/lib/tftpboot/images/centos/7.6/initrd.img’
‘boot/images/centos/7.6/vmlinuz’ -> ‘/var/lib/tftpboot/images/centos/7.6/vmlinuz’
‘boot/images/redhat/6.6/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/6.6/initrd.img’
‘boot/images/redhat/6.6/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/6.6/vmlinuz’
‘boot/images/redhat/6.7/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/6.7/initrd.img’
‘boot/images/redhat/6.7/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/6.7/vmlinuz’
‘boot/images/redhat/6.8/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/6.8/initrd.img’
‘boot/images/redhat/6.8/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/6.8/vmlinuz’
‘boot/images/redhat/6.9/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/6.9/initrd.img’
‘boot/images/redhat/6.9/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/6.9/vmlinuz’
‘boot/images/redhat/7.0/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/7.0/initrd.img’
‘boot/images/redhat/7.0/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/7.0/vmlinuz’
‘boot/images/redhat/7.1/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/7.1/initrd.img’
‘boot/images/redhat/7.1/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/7.1/vmlinuz’
‘boot/images/redhat/7.2/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/7.2/initrd.img’
‘boot/images/redhat/7.2/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/7.2/vmlinuz’
‘boot/images/redhat/7.3/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/7.3/initrd.img’
‘boot/images/redhat/7.3/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/7.3/vmlinuz’
‘boot/images/redhat/7.4/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/7.4/initrd.img’
‘boot/images/redhat/7.4/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/7.4/vmlinuz’
‘boot/images/redhat/7.5/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/7.5/initrd.img’
‘boot/images/redhat/7.5/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/7.5/vmlinuz’
‘boot/images/redhat/7.6/initrd.img’ -> ‘/var/lib/tftpboot/images/redhat/7.6/initrd.img’
‘boot/images/redhat/7.6/vmlinuz’ -> ‘/var/lib/tftpboot/images/redhat/7.6/vmlinuz’
‘boot/kickstarts/ks.cfg’ -> ‘/var/www/html/kickstarts/ks.cfg’
ks.cfg is create Successful
/var/lib/tftpboot/pxelinux/pxelinux.cfg/default is create Successful
/var/lib/tftpboot/uefi/grub.cfg is create Successful
/var/lib/tftpboot/efi/efidefault is create Successful
[INFO]	2019-01-07 17:50:37 check need to install os file (script:config_pxe.sh function: main line:145)
ls: cannot access to_iso/*.iso: No such file or directory
**************************************************
from_iso/CentOS-7-x86_64-DVD-1810.iso
**************************************************
Confirm whether to continue?[y/n]y
umount: /var/www/html/os/redhat/6.6: not mounted
mount: /dev/loop1 is write-protected, mounting read-only
Redirecting to /bin/systemctl stop iptables.service
Failed to stop iptables.service: Unit iptables.service not loaded.
error reading information on service iptables: No such file or directory
[INFO]	2019-01-07 17:50:41 Iptables closed successfully (script:config_pxe.sh function: main line:187)
Restarting network (via systemctl):                        [  OK  ]
[INFO]	2019-01-07 17:50:43 network restart success (script:config_pxe.sh function: main line:192)
[INFO]	2019-01-07 17:50:43 allow service tftp boot enabled and start (script:config_pxe.sh function: main line:199)
[INFO]	2019-01-07 17:50:44 allow service dhcp boot enabled and start (script:config_pxe.sh function: main line:202)
[INFO]	2019-01-07 17:50:44 allow service xinetd boot enabled and start (script:config_pxe.sh function: main line:205)
[INFO]	2019-01-07 17:50:44 allow service http boot enabled and start (script:config_pxe.sh function: main line:208)
```

### 3.2、功能选项【2】：更换PXE批量安装的服务器

​	此功能是针对PXE服务器已经安装好了，但是需要修改批量安装的操作系统，只需要上传新的操作系统镜像文件到to_iso目录下即可。

### 3.3、功能选项【3】：批量修改文件内容

​	该功能主要是为了修改配置文件中的某些不符合配置项。可以使用该功能注解配置、替换内容、删除内容。

```shell
输入功能选项：3
Please input [0-9,a-j,q,r]: 3
批量修改文件内容
[INFO]	2019-01-07 18:02:30 **********************************START************************************** (script:start_itennis.sh function: remote_exe_changeconfig display display display main line:19)
please input old value: old 		#输入旧值
please input new value: new			#输入新值
please input modify file: /file.txt	#输入修改的文件

例如：该错误是当前节点的“/etc/sudoers”文件中“Defaults requiretty”配置错误。
输入功能选项：3
Please input [0-9,a-j,q,r]: 3
批量修改文件内容
[INFO]	2019-01-07 18:02:30 **********************************START************************************** (script:start_itennis.sh function: remote_exe_changeconfig display display display main line:19)
please input old value: Defaults requiretty 		
please input new value: 			
please input modify file: /etc/sudoers
可以删除所有节点上的“Defaults requiretty”的值，如果new value写“# Defaults requiretty”，则会注解该值。

```

### 3.4、功能选项【4】：批量双网卡绑定Bond模式配置

1）修改配置文件：conf/bond_and_team.conf

```shell
例如：本配置写了两个绑定接口bond0和bond1，可以配置多个绑定接口
#临时IP地址	用户名	密码	[绑定接口	模式	绑定地址	掩码	网关 子接口1	子接口2]	...	[绑定接口	模式	绑定地址	掩码	网关 子接口1	子接口2]
10.0.128.113	root	root	bond0	1	10.9.9.10	255.0.0.0	10.0.0.1	eth0	eth1	bond1	1	11.9.9.10	255.0.0.0	11.0.0.1	eth2	eth3

说明：通过ssh连接到10.0.128.113，配置该服务器上bond0:eth0和eth1，bond1：eth2和eth3,做两组bond网卡，每一行表示一台服务器，每组“【】”表示为一组Bond信息，可以为多组，每一行Bond个数不需要一致。
```

2）运行sh start_itennis.sh脚本，选择功能4，完成双网卡绑定

### 3.5、功能选项【5】：批量双网卡绑定Bond模式配置

参照功能【4】选项。

### 3.6、功能选项【6】：收集LLD配置信息,检查网络连通性

主要批量检查网络的连通性和收集硬件信息，其中 包括CPU的core、内存、磁盘数、磁盘详细情况。

1）配置文件conf/hosts.list

```shell
#管理地址       业务地址        用户名  密码
10.0.128.108    10.0.128.108    root    123456

说明：如果为单平面，管理地址和业务地址写一样即可。
```

2）运行sh start_itennis.sh脚本，选择功能6，完成配置信息收集，收集的信息存放datas/lld.conf和datas/lld.txt文件中，其中N/A表示没有ping通，网络连通性存在问题。

```shell
[root@localhost iTennis-Lopt]# cat datas/lld.conf 
#管理地址	CPU虚拟核数	内存(G)	主机逻辑磁盘数量	磁盘情况
10.0.128.108	N/A	N/A	N/A	N/A
```

### 3.7、功能选项【a】：解决SSH慢的问题

​	主要解决PXE服务器批量安装操作系统以后，由于DHCP导致nameserver存在域名解析超时问题，故用来解决SSH连接慢的问题。

### 3.8、功能选项【b】：时区和时间配置

​	配置上海时区，如果直接回车不输入时间，配置远端为当前操作系统时间，如果后面手动输入时间，配置以后面输入为主。主要解决时间不同步问题。

```shell
Please input [0-9,a-j,q,r]: b
时区和时间配置
[INFO]	2019-01-07 18:20:06 **********************************START************************************** (script:start_itennis.sh function: config_time_zero display main line:85)
please input  current time[2019-01-07 18:20:07]:
```



### 3.9、功能选项【c】：本地Yum仓库源配置

​	配置本地Yum仓库源，可以补全需要的rpm包，默认把镜像放在from_iso文件下，可以手动挂载在/media下。

### 3.10、功能选项【d】：批量配置YUM源

​	配置远端操作系统Yum源为http源，默认仓库为pxe的服务器地址。配置文件为conf/hosts.list，可以采用#注释。

### 3.11、功能选项【e】：批量更换IP地址

说明：网卡名称不写，默认为当前IP所在网卡，如果存在，则修改配置的网卡名的ip地址为新IP，旧IP地址不更新。没一行代表一台服务器，每个“【】”为一组，可以修改一台服务器的n组地址，每台服务器可以修改的数量不一致。

```shell
#用户名	密码	[旧IP	新IP	新掩码	新网关]	...	[旧IP	新IP	新掩码	新网关]
root	123456	10.0.128.108 10.0.129.109 255.0.0.0 10.0.0.1	10.0.128.111 10.0.129.111 255.0.0.0 11.0.0.1

说明：运行脚本后，ssh到10.0.128.108地址，然后将10.0.128.108修改为10.0.0.1，以此类推。
```



### 3.12、功能选项【f】：批量配置RAID

​	配置文件使用conf/hosts.list，默认会在/opt/下生成it_raid0.sh和it_raid1.sh，两个raid脚本，可以和批量执行功能选项合用。

### 3.13、功能选项【g】：批量配置BMC地址

​	配置文件使用conf/bmc_ip.conf，

```shell
#临时IP(提供SSH)	用户名	密码	BMC地址	BMC掩码	BMC网关
10.0.128.108	root	123456	11.0.0.128	255.0.0.0	11.0.0.1

说明：脚本会通过ssh连接到10.0.128.108地址的服务器上，然后配置BMC的地址为11.0.0.128及掩码和网关。
```

### 3.14、功能选项【h】：解决重装操作系统无法引导

​	该问题出现主要是因为第一次安装操作系统后，有遗留引导文件，下一次再安装操作系统时候，会导致旧的引导和新的引导混乱，导致操作系统无法启动。配置文件使用的是conf/hosts.list，“#”可以注解。

### 3.15、功能选项【i】：本机免密钥通信

​	改操作主要是建立本机和其他机器之间的免密钥通信，本操作系统连接其他服务器不需要输入密码，配置文件使用的是conf/hosts.list，“#”可以注解。

