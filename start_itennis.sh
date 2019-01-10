#!/bin/bash
isContinue='y'
function isNext()
{
        read -p 'Confirm whether to continue?[y/n]' isContinue
        if [ "$isContinue" = "n" ];then
                exit;
        fi
}
source_functions()
{
        . conf/itennis.conf
        . scripts/log_print
        . scripts/exec_remote
	. scripts/packets_install
}
function remote_exe_changeconfig()
{
	log INFO "**********************************START**************************************"
	read -p "please input old value: "
        oldv=$REPLY
	read -p "please input new value: "
        newv=$REPLY
	read -p "please input modify file: "
        vfile=$REPLY
	sh remote_change_config "$oldv" "$newv" "$vfile"
	log INFO "***********************************END***************************************"
}
function remote_exe_cmd()
{
	log INFO "**********************************START**************************************"
	read -p "please input command: " 
	sh remote_cmd "$REPLY" 
	log INFO "***********************************END***************************************"
}
function remote_exe_scp()
{
	log INFO "**********************************START**************************************"
	read -p "please input scp origin: " 
	sour=$REPLY
	read -p "please input  scp destination:" 
	dest=$REPLY
	sh remote_scp "$sour" "$dest"
	log INFO "***********************************END***************************************"
}
function remote_exe_copytolocal()
{
	log INFO "**********************************START**************************************"
	read -p "please input copy origin: " 
	sour=$REPLY
	read -p "please input  copy destination:" 
	dest=$REPLY
	sh remote_tolocal "$sour" "$dest"
	log INFO "***********************************END***************************************"
}
function ssh_to_otherswithonpwd()
{
	log INFO "**********************************START**************************************"
	hostfile=conf/hosts.list
	read -p "please input host list file[$hostfile]: " INPUT
	if [ x$INPUT != x ]; then
	    hostfile=$INPUT
	fi
	log INFO "ssh others with on password in $hostfile start"	
	sh scripts/sshx_to_others_with_nopwd $hostfile
	log INFO "ssh others with on password in $hostfile end"
	log INFO "***********************************END***************************************"
}
function clear_mbr()
{
	log INFO "**********************************START**************************************"
	echo -e "\033[31m[NOTE] 清除MBR后，当前操作系统重启后将不能引导正常引导，主要解决重装操作系统不能正常引导问题!!!\033[0m"	
	isNext
	dd if=/dev/zero of=/dev/sda bs=1k count=1 && log INFO 'Clear MBR OK' || log ERROR 'Clear MBR failed'
	log INFO "***********************************END***************************************"
}
function deal_slow_ssh()
{
	log INFO "**********************************START**************************************"
	sh remote_cmd "sed -i "/UseDNS/d" /etc/ssh/sshd_config ;echo 'UseDNS no' >> /etc/ssh/sshd_config;sed -i '/^nameserver/d' /etc/resolv.conf;service sshd restart"
	log INFO "***********************************END***************************************"
}
function config_time_zero()
{
	log INFO "**********************************START**************************************"
	ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;hwclock &> /dev/null
	read -p "please input  current time[`date \"+%Y-%m-%d %H:%M:%S\"`]:"
	if [ "`echo $REPLY`" != "" ];then
		date -s "$REPLY" &> /dev/null
	fi
	sh remote_cmd "ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;hwclock &> /dev/null;date -s \"`date`\" &> /dev/null"
	log INFO "***********************************END***************************************"
}

function batch_bond()
{
	log INFO "**********************************START**************************************"
	timeout=$REMOTE_TIMEOUT
        port=$REMOTE_PORT
	tmpdir=$TMPDIR
	src="tools/bonding.sh"
	grep -v "^#" conf/bond_and_team.conf | while read line
        do
                arr=(${line///\t/ })
                length=${#arr[@]}
                tmpv=$(( ($length-3)%7 ))
                if [ $tmpv != 0 ];then
                        log ERROR "Please check conf/bond_and_team.conf files failed"
                        exit
                fi
                tmpx=$(( ($length-3)/7 ))
                cmd=""
                for (( i=0;i<tmpx;i++ ))
                do
                        cmd=$cmd"sh $TMPDIR/bonding.sh ${arr[i*7+3]} ${arr[i*7+4]} ${arr[i*7+5]} ${arr[i*7+6]} ${arr[i*7+7]}  ${arr[i*7+8]}  ${arr[i*7+9]};"
                done
                log DEBUG "exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} \"$cmd\""
		ping -c 3 -i 0.2 -W 3 ${arr[0]} &> /dev/null
                if [ $? -eq 0 ];then
                        log INFO "ping ${arr[0]} success"
                else
                        log ERROR "ping ${arr[0]} failed"
                        continue
                fi
                exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "mkdir -p $tmpdir"
                cp_file_to_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "$src" "$tmpdir"
		exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "$cmd"
		exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "rm -rf $tmpdir"
		log WARN "Modification Configuration Completed,Network is restarting..."
		exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "service network restart" &> /dev/null
        done
	log INFO "***********************************END***************************************"

}
function batch_team()
{
	log INFO "**********************************START**************************************"
        timeout=$REMOTE_TIMEOUT
        port=$REMOTE_PORT
        tmpdir=$TMPDIR
        src="tools/teaming.sh"
        grep -v "^#" conf/bond_and_team.conf | while read line
        do
                arr=(${line///\t/ })
                length=${#arr[@]}
                tmpv=$(( ($length-3)%7 ))
                if [ $tmpv != 0 ];then
                        log ERROR "Please check conf/bond_and_team.conf files failed"
                        exit
                fi
                tmpx=$(( ($length-3)/7 ))
                cmd=""
                for (( i=0;i<tmpx;i++ ))
                do
                        cmd=$cmd"sh $TMPDIR/teaming.sh ${arr[i*7+3]} ${arr[i*7+4]} ${arr[i*7+5]} ${arr[i*7+6]} ${arr[i*7+7]} ${arr[i*7+8]} ${arr[i*7+9]};"
                done
		log DEBUG "exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} \"$cmd\""
                ping -c 3 -i 0.2 -W 3 ${arr[0]} &> /dev/null
                if [ $? -eq 0 ];then
                        log INFO "ping ${arr[0]} success"
                else
                        log ERROR "ping ${arr[0]} failed"
                        continue
                fi
                exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "mkdir -p $tmpdir"
                cp_file_to_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "$src" "$tmpdir"
                exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "$cmd"
                exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "rm -rf $tmpdir"
		log WARN "Modification Configuration Completed,Network is restarting..."
                exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "service network restart" &> /dev/null

        done
	log INFO "***********************************END***************************************"

}
function change_ip()
{
	log INFO "**********************************START**************************************"
	timeout=$REMOTE_TIMEOUT
        port=$REMOTE_PORT
	tmpdir=$TMPDIR
        src="tools/change_ip_tmp.sh"
	grep -v "^#" conf/change_ip.conf | while read line
        do
                arr=(${line///\t/ })
                length=${#arr[@]}
                tmpv=$(( ($length-2)%4 ))
                if [ $tmpv != 0 ];then
                        log ERROR "Please check conf/change_ip.conf files failed"
                        exit
                fi
                tmpx=$(( ($length-2)/4 ))
                cmd=""
                for (( i=0;i<tmpx;i++ ))
                do
			cmd=$cmd"sh $TMPDIR/change_ip_tmp.sh ${arr[i*4+2]} ${arr[i*4+3]} ${arr[i*4+4]} ${arr[i*4+5]};"
                done
		log DEBUG "exec_cmd_r $port $timeout ${arr[2]} ${arr[0]} ${arr[1]} \"$cmd\""
		exec_cmd_r $port $timeout ${arr[2]} ${arr[0]} ${arr[1]} "mkdir -p $tmpdir"
                cp_file_to_r $port $timeout ${arr[2]} ${arr[0]} ${arr[1]} "$src" "$tmpdir"
                exec_cmd_r $port $timeout ${arr[2]} ${arr[0]} ${arr[1]} "$cmd"
                exec_cmd_r $port $timeout ${arr[2]} ${arr[0]} ${arr[1]} "rm -rf $tmpdir"
		log WARN "Modification Configuration Completed,Network is restarting..."
                exec_cmd_r $port $timeout ${arr[2]} ${arr[0]} ${arr[1]} "service network restart" &> /dev/null
	done
	log INFO "***********************************END***************************************"
}
function batch_config_bmcinfo()
{
	log INFO "**********************************START**************************************"
        timeout=$REMOTE_TIMEOUT
        port=$REMOTE_PORT
        tmpdir=$TMPDIR
        src="tools/ipmi_ip_config.sh"
        grep -v "^#" conf/bmc_ip.conf | while read line
        do
                arr=(${line///\t/ })
                length=${#arr[@]}
                cmd=""
                cmd="sh $TMPDIR/ipmi_ip_config.sh ${arr[3]} ${arr[4]} ${arr[5]};"
		log DEBUG "exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} \"$cmd\""
		exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "mkdir -p $tmpdir"
                cp_file_to_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "$src" "$tmpdir"
                exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "$cmd"
                exec_cmd_r $port $timeout ${arr[0]} ${arr[1]} ${arr[2]} "rm -rf $tmpdir"
        done
	log INFO "***********************************END***************************************"
}
function batch_yum_completed()
{
	log INFO "**********************************START**************************************"
	serverip=$SERVER_IP
	tmpdir=$TMPDIR
	src="tools/yum_remote.sh"
	sh remote_cmd "mkdir -p $tmpdir"
	sh remote_scp "$src" "$tmpdir"
	sh remote_cmd "sh $tmpdir/yum_remote.sh $serverip/os/$INSTALL_OS/$OS_VERSION"
	sh remote_cmd "rm -rf $tmpdir"
	log INFO "***********************************END***************************************"
}
function make_raid()
{
	log INFO "**********************************START**************************************"
	src="tools/megacli"
	tmpdir=$TMPDIR
	sh remote_cmd "mkdir -p $tmpdir"
	sh remote_scp "$src" "$tmpdir"
	sh remote_cmd "sh $tmpdir/megacli/check.sh"
	sh remote_cmd "rm -rf $tmpdir"
	log INFO "***********************************END***************************************"
}
function display()
{
echo "****************************************Please Input***********************************"
echo "**  [1]：配置PXE环境                      **  [a]：解决SSH慢的问题                   **"
echo "**  [2]：更换PXE批量安装的服务器          **  [b]：时区和时间配置                    **"
echo "**  [3]：批量修改文件内容                 **  [c]：本地Yum仓库源配置                 **"
echo "**  [4]：批量双网卡绑定Bond模式配置       **  [d]：批量配置YUM源                     **"
echo "**  [5]：批量双网卡绑定Team模式配置       **  [e]：批量更换IP地址                    **"
echo "**  [6]：收集LLD配置信息,检查网络连通性   **  [f]：批量配置RAID                      **"             
echo "**  [7]：批量拷贝文件                     **  [g]：批量配置BMC地址                   **"
echo "**  [8]：批量执行命令                     **  [h]：解决重装操作系统无法引导          **"
echo "**  [9]：批量拷贝文件到本地               **  [i]：本机免密钥通信                    **"
echo "**  [q]：退出                             **  [j]：单机配置Bond双网卡绑定            **"
echo "**  [r]：重启                             **  [r]：重启                              **"
echo "******************************@iTennis By xiehuisheng@hotmial.com**********************"
read -p "Please input [0-9,a-j,q,r]: " INPUT
case "$INPUT" in
[1] ) echo "配置PXE环境"                         ;sh pxe_config.sh;;
[2] ) echo "更换PXE批量安装的服务器"             ;sh change_pxeos_version;;
[3] ) echo "批量修改文件内容"                    ;remote_exe_changeconfig;;
[4] ) echo "批量双网卡绑定Bond模式配置"          ;batch_bond;;
[5] ) echo "批量双网卡绑定Team模式配置"          ;batch_team;;
[6] ) echo "收集LLD配置信息,检查网络连通性"      ;sh check_lld;;
[7] ) echo "批量拷贝文件"                        ;remote_exe_scp;;
[8] ) echo "批量执行命令"                        ;remote_exe_cmd;;
[9] ) echo "批量拷贝文件到本地"                  ;remote_exe_copytolocal;;
[a] ) echo "解决SSH慢的问题"                     ;deal_slow_ssh;;
[b] ) echo "时区和时间配置"                      ;config_time_zero;;
[c] ) echo "本地Yum仓库源配置"                   ;sh scripts/yum_config;;
[d] ) echo "批量补全YUM包"                       ;batch_yum_completed;;
[e] ) echo "批量配置IP地址"                      ;change_ip;;
[f] ) echo "批量配置RAID"                        ;make_raid;;
[g] ) echo "配置配置BMC地址"                     ;batch_config_bmcinfo;;
[h] ) echo "解决重装操作系统无法引导"            ;clear_mbr;;
[i] ) echo "本机免密钥通信"                      ;ssh_to_otherswithonpwd;;
[j] ) echo "单机配置Bond双网卡绑定"              ;sh scripts/bonding;;
[q] ) echo "退出"                                ;exit 0;;
[r] ) echo "重启"                                ;reboot;;
* ) echo "Input Error!" ;;
esac
echo -e "\n"
display
}
source_functions
display
