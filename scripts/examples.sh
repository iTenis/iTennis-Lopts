./remote.sh -i 192.168.38.141 -p root -m scp-out -s /tmp/yum.log -d /tmp/yum.log
./remote.sh -i 192.168.38.141 -p root -t 5 -m ssh-cmd -c "ls ~"
