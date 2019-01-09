#!/bin/bash
yum_dir="/etc/yum.repos.d"
if [ ! -d "${yum_dir}/bak" ]; then
        mkdir ${yum_dir}/bak
fi

mv ${yum_dir}/*.repo ${yum_dir}/bak/
(
cat << EOF
[remote]
name=remote
baseurl=http://$1
gpgcheck=0
enabled=1
EOF
) > ${yum_dir}/remote.repo
