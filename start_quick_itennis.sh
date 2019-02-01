#!/bin/bash
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
source_functions()
{
        . conf/itennis.conf
        . scripts/log_print
        . scripts/exec_remote
	. scripts/packets_install
}
function ssh_to_otherswithonpwd()
{
        hostfile=conf/hosts.list
        read -p "please input host list file[$hostfile]: " INPUT
        if [ x$INPUT != x ]; then
            hostfile=$INPUT
        fi
        log INFO "ssh others with on password in $hostfile start"
        sh scripts/sshx_to_others_with_nopwd $hostfile
        log INFO "ssh others with on password in $hostfile end"
}
function remote_exe_changeconfig()
{
        read -p "please input old value: "
        oldv=$REPLY
        read -p "please input new value: "
        newv=$REPLY
        read -p "please input modify file: "
        vfile=$REPLY
	cmd="sed -i 's/$oldv/$newv/g' $vfile"
	CMDS_LIST=/tmp/cmds_list.$$
	CONF_LIST=${HOSTS_CONF}
	BG='y'
(
cat << EOF
if [[ \`grep -v '^#' $vfile | grep -i '$newv' | wc -l\` == 0 || '$newv' == '' ]];then  $cmd; fi
EOF
) > ${CMDS_LIST}

	sh exec_morelist.sh ${CONF_LIST} ${CMDS_LIST} $BG
	rm /tmp/*.$$
}
function clear_mbr()
{
        echo -e "\033[31m[NOTE] 清除MBR后，当前操作系统重启后将不能引导正常引导，主要解决重装操作系统不能正常引导问题!!!\033[0m"        
        isNext
        CMDS_LIST=/tmp/cmds_list.$$
        CONF_LIST=${HOSTS_CONF}
        BG='y'
(
cat << EOF
dd if=/dev/zero of=/dev/sda bs=1k count=1 && echo 'Clear MBR OK' || echo 'Clear MBR failed'
EOF
) > ${CMDS_LIST}

        sh exec_morelist.sh ${CONF_LIST} ${CMDS_LIST} $BG
        rm /tmp/*.$$
}

function config_time_zero()
{
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;hwclock &> /dev/null
        read -p "please input  current time[`date \"+%Y-%m-%d %H:%M:%S\"`]:"
        if [ "`echo $REPLY`" != "" ];then
                date -s "$REPLY" &> /dev/null
        fi
        CMDS_LIST=/tmp/cmds_list.$$
        CONF_LIST=${HOSTS_CONF}
        BG='y'
(
cat << EOF
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;hwclock &> /dev/null;date -s \"`date`\" &> /dev/null
EOF
) > ${CMDS_LIST}

        sh exec_morelist.sh ${CONF_LIST} ${CMDS_LIST} $BG
        rm /tmp/*.$$
}

function batch_yum_completed()
{
	serverip=$SERVER_IP
        tmpdir=$TMPDIR
        src="tools/yum_remote.sh"
        CMDS_LIST=/tmp/cmds_list.$$
	CMDS2_LIST=/tmp/cmds2_list.$$
        CONF_LIST=${HOSTS_CONF}
        BG='y'
(
cat << EOF
mkdir -p $tmpdir
EOF
) > ${CMDS_LIST}
        sh exec_morelist.sh ${CONF_LIST} ${CMDS_LIST} $BG
	sh exescp_list.sh $CONF_LIST $src $tmpdir
(
cat << EOF
sh $tmpdir/yum_remote.sh $serverip/os/$INSTALL_OS/$OS_VERSION
rm -rf $tmpdir
EOF
) > ${CMDS2_LIST}

        sh exec_morelist.sh ${CONF_LIST} ${CMDS2_LIST} $BG
        rm /tmp/*.$$
}

function batch_config_bmcinfo()
{
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
}
function batch_bond()
{
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

}
function batch_team()
{
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

}
function change_ip()
{
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
}
function batch_change_rootpwd()
{
        CMDS_LIST=/tmp/cmds_list.$$
        CONF_LIST=${HOSTS_CONF}
        BG='y'
	read -p "please input root new password: "
        newpwd=$REPLY
    
(
cat << EOF
echo $newpwd | passwd --stdin root
EOF
) > ${CMDS_LIST}

        sh exec_morelist.sh ${CONF_LIST} ${CMDS_LIST} $BG
        rm /tmp/*.$$
}
function more_funcitons()
{
	echo "developing..."
}
function display()
{
echo "****************************************Please Input***********************************"
echo "**  [1]：配置PXE环境                      **  [a]：解决重装操作系统无法引导          **"
echo "**  [2]：批量双网卡绑定Bond模式配置       **  [b]：批量双网卡绑定Team模式配置        **"
echo "**  [3]：时区和时间配置                   **  [c]：本机免密钥通信                    **"
echo "**  [4]：批量配置RAID                     **  [d]：批量更换IP地址                    **"
echo "**  [5]：收集硬件配置信息,检查网络连通性  **  [e]：批量配置BMC地址                   **"
echo "**  [6]：批量配置YUM源                    **  [f]：本地Yum仓库源配置                 **"
echo "**  [7]：批量拷贝文件                     **  [g]：批量修改文件内容                  **"
echo "**  [8]：批量执行命令                     **  [h]：批量更换Root密码                  **"
echo "**  [9]：批量拷贝文件到本地               **  [i]：检查文件权限及属组                **"
echo "**  [q]：退出                             **  [m]：更多                              **"
echo "***********************@iTennis By xiehuisheng@hotmial.com*****************************"
read -p "Please input [0-9,a-j,q,r]: " INPUT
case "$INPUT" in
[1] ) echo "配置PXE环境"                                  ;sh pxe_config.sh;;
[2] ) echo "批量双网卡绑定Bond模式配置"                   ;batch_bond;;
[3] ) echo "时区和时间配置"                               ;config_time_zero;;
[4] ) echo "批量配置RAID"                                 ;sh make_raid;;
[5] ) echo "收集硬件配置信息,检查网络连通性"              ;sh check_lld;;
[6] ) echo "批量配置YUM源"                                ;batch_yum_completed;;
[7] ) echo "批量拷贝文件"                                 ;sh generate_scps.sh;;
[8] ) echo "批量执行命令"                                 ;sh generate_input_cmd.sh;;
[9] ) echo "批量拷贝文件到本地"                           ;sh generate_scp_tolocal.sh;;
[a] ) echo "解决重装操作系统无法引导"                     ;clear_mbr;;
[b] ) echo "批量双网卡绑定Team模式配置"                   ;batch_team;;
[c] ) echo "本机免密钥通信"                               ;ssh_to_otherswithonpwd;;
[d] ) echo "批量更换IP地址"                               ;change_ip;;
[e] ) echo "批量配置BMC地址"                              ;batch_config_bmcinfo;;
[f] ) echo "本地Yum仓库源配置"                            ;sh scripts/yum_config;;
[g] ) echo "批量修改文件内容"                             ;remote_exe_changeconfig;;
[h] ) echo "批量更换Root密码"                             ;batch_change_rootpwd;;
[i] ) echo "检查文件权限及属组"                           ;sh check_permission;;
[m] ) echo "更多"                                         ;more_functions;;
[q] ) echo "退出"                                         ;exit 0;;
* ) echo "Input Error!" ;;
esac
echo -e "\n"
display
}
help()
{
	echo "This is a generic command line parser demo."
	echo "USAGE EXAMPLE: ./cmdparser -l hello -f -- -somefile1 somefile2"
	echo "HELP"
	exit 0
}
source_functions
#PS4="#[Note]:"
#set -x
if [ ! -n "$1" ];then
	display
elif [[ "$1" = "-v"  ]];then
	echo "iTennis version:$VERSION"
fi
