#!/bin/bash
#$1是虚拟机号
#$2是网段
#$3是主机号
#$4是主机名
a=$1
b=$2
c=$3
add="nmcli connection add type ethernet con-name eth1 ifname eth1"
nmcli="nmcli connection modify eth0 ipv4.method manual ipv4.address '192.168.$b.$c/24' connection.autoconnect yes"
nmcli1="nmcli connection modify eth1 ipv4.method manual ipv4.address '192.168.$b.$c/24' connection.autoconnect yes"

rpm -q expect
if [ $? -ne 0 ];then
   yum -y install expect
fi

[ -d /xk/yum.repos.d ] || mkdir -p /xk/yum.repos.d/ 
echo "[rhel7]
name=xiangkui
baseurl=ftp://192.168.$b.254/rhel7
enabeld=1
gpgcheck=0" > /xk/yum.repos.d/dvd.repo
expect <<  EOF
spawn clone-vm7
expect "number:" {send "$a\r"}
expect "#"          { send "exit\r" }
EOF
virsh start "rh7_node$a"
sleep 2
if [ $b -eq 2 ];then
   expect << EOF
   spawn virsh console "rh7_node$a"
   expect "换码符为 ^]" {send "root\r"}
   expect "login:" {send "root\r"}
   expect "login:" {send "root\r"}
   expect "密码："  {send "123456\r"}
   expect "#" {send "hostnamectl set-hostname $4\r"}
   expect "#"  {send "$add\r"}
   expect "#"   {send "$nmcli1\r"}
   expect "#" {send "nmcli connection up eth1\r"}
   expect "#"  {send "exit\r"}
EOF
else 
   expect << EOF
   spawn virsh console "rh7_node$a"
   expect "换码符为 ^]" {send "root\r"}
   expect "login:" {send "root\r"}
   expect "login:" {send "root\r"}
   expect "密码："  {send "123456\r"}
   expect "#" {send "hostnamectl set-hostname $4\r"}
   expect "#"   {send "$nmcli\r"}
   expect "#" {send "nmcli connection up eth0\r"}
   expect "#"  {send "exit\r"}
EOF
fi
sleep 5

expect << EOF
spawn scp "/xk/yum.repos.d/dvd.repo" "root@192.168.$b.$c:/etc/yum.repos.d/"
expect "(yes/no)?" {send "yes\r"}
expect "password:" {send "123456\r"}
expect "#"  {send "exit\r"}
EOF

