

#备注
#1.cobbler_auto_part.sh 脚本安装的cobbler 为后面安装系统主动分区
#2.cobbler_manual_part.sh 为脚本安装的cobbler 为后面安装系统自定义分区
#3.使用脚本前确定网卡名称，镜像是否连接系统。

#!/bin/bash

down_cobbler()
{
#关闭防火墙，安全性
systemctl stop firewalld
setenforce 0
echo -e "\033\t[34m 正在下载cobbler相关软件包 ... \033[0m" && sleep 1
rpm -ivh https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-13.noarch.rpm &&yum makecache && yum install cobbler cobbler-web dhcp tftp-server pykickstart httpd rsync xinetd tree -y
}

#修改cobble,fttpr配置文件

setup_file()
{
echo -e "\033\t[34m 正在修改cobbler相关配置文件 ... \033[0m" && sleep 1
net=`ifconfig ens33 | grep "netmask" |awk '{print $2}' |awk -F "." '{print $1"."$2"."$3}'`
ip=`ifconfig ens33 | grep "netmask" | awk '{print $2}'`
pass=`openssl passwd -1 -salt 'abc123' 'abc123' `
sed -i "101c default_password_crypted: \"$pass\"" /etc/cobbler/settings
sed -i "s/^server: 127.0.0.1/server: $ip/" /etc/cobbler/settings
sed -i "s/^next_server: 127.0.0.1/next_server: $ip/" /etc/cobbler/settings
sed -i "s/manage_dhcp: 0/manage_dhcp: 1/" /etc/cobbler/settings
sed -i "14s/yes/no/" /etc/xinetd.d/tftp
#修改dhcp模板
sed -i "21s/192.168.1/$net/g" /etc/cobbler/dhcp.template
sed -i "22s/192.168.1.5/$net.1/g" /etc/cobbler/dhcp.template
sed -i "23s/192.168.1.1/$net.2/g" /etc/cobbler/dhcp.template
sed -i "25s/192.168.1.100 192.168.1.254/$net.150 $net.200/" /etc/cobbler/dhcp.template
#启动服务
systemctl enable rsyncd
systemctl start rsyncd
systemctl start xinetd
}

#cobbler 同步

cobbler_sync()
{
echo -e "\033\t[34m cobbler 正在同步 ... \033[0m" && sleep 1
systemctl start httpd && systemctl start cobblerd &&sleep 2 && cobbler sync && systemctl restart dhcpd
}

#下载引导操作系统文件和导入系统镜像

loader_images()
{
echo -e "\033\t[34m 正在下载引导操作系统文件和导入系统镜像 ... \033[0m" && sleep 1
cobbler get-loaders && sleep 2 && mount /dev/sr0 /mnt &&cobbler import --path=/mnt/ --name=CentOS-7-x86_64 --arch=x86_64
}

disk_sub(){
cd /var/lib/cobbler/kickstarts/
cp sample_end.ks redhat7.ks
sed -i "s/autopart/#autopart/" redhat7.ks
sed -i '44ipart /boot --fstype="xfs" --size=1024'redhat7.ks
sed -i '45ipart swap --fstype="swap" --size=4096' redhat7.ks
sed -i '46ipart / --fstype="xfs" --grow --size=1' redhat7.ks
sed -i '57ilrzsz' redhat7.ks
sed -i '58inet-tools.x86_64' redhat7.ks
cobbler profile edit --name=CentOS-7-x86_64 --kickstart=/var/lib/cobbler/kickstarts/redhat7.ks
cobbler sync
sleep 2
}

check_service()
{
echo -e "\033\t[34m 正在检查所有服务状态 ... \033[0m" && sleep 1
echo -e "\033\t[34m 正在检查所有服务状态 ... \033[0m" && sleep 1
http=`netstat -ntap | grep :80 | wc -l`
cob=`systemctl status cobblerd | grep "active (running)" | wc -l `
os=`cobbler distro list | wc -l `
syn=`cobbler sync |wc -l`
dhcp=`systemctl status dhcpd | grep "active (running)" | wc -l `
load=`cobbler get-loaders | grep "already exists" | wc -l`
tftp=`systemctl status xinetd | grep "active (running)" | wc -l`
if [ $http -ne 0 ] && [ $cob -eq 1 ] && [ $os -eq 1 ] && [ $syn -gt 1 ] && [ $dhcp -eq 1 ] && [ $load -gt 1 ] && [ $tftp -eq 1 ];then
echo -e "\033\t[34m 所有服务运行正常! \033[0m"
else echo -e "\033\t[31m error,check ! \033[0m"
exit 0
fi
}


main()
{
down_cobbler
setup_file
cobbler_sync &&loader_images
disk_sub &&check_service
}

#执行函数
main