#!/bin/bash
#nagios agent install
#首先将nrpe-2.13.tar.gz 和nagios-plugins-1.4.13.tar.gz 以及监控脚本check_disk_zzy分发到每台服务器/root 目录下
#再将此脚本分发下去，执行,在监控端的/usr/local/nagios/etc/objects/servers 目录下，添加对应的被监控端的配置文件

yum install -y gcc glibc glibc-common gd gd-devel xinetd openssl-devel
useradd nagios &>/dev/null 

tar -zxvf /root/nagios-plugins-1.4.13.tar.gz
cd /root/nagios-plugins-1.4.13
./configure --prefix=/usr/local/nagios
make && make install
cd /root/
tar -zxvf /root/nrpe-2.13.tar.gz -C /root/
cd /root/nrpe-2.13
./configure
make all
make install-plugin
make install-daemon
make install-daemon-config

#修改被监控端的配置文件，添加被监控端IP和监控的项目
sed -i 's@allowed_hosts=127.0.0.1@allowed_hosts=127.0.0.1,117.28.243.18,117.28.242.133@' /usr/local/nagios/etc/nrpe.cfg
echo -e 'command[check_disk_zzy]=/usr/local/nagios/libexec/check_disk_zzy -w 70 -c 80' >> /usr/local/nagios/etc/nrpe.cfg
echo -e 'command[check_salt]=/usr/local/nagios/libexec/check_procs -w 1:1 -C salt-minion' >> /usr/local/nagios/etc/nrpe.cfg

mv /root/check_disk_zzy /usr/local/nagios/libexec/ -f
chmod 755 /usr/local/nagios/libexec/*

/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
echo '/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d' >> /etc/rc.local

#添加防火墙
iptables -I INPUT -p tcp -m multiport --dports 5666 -j ACCEPT
service iptables save &>/dev/null

nrpe=`ps -ef | grep -c "nrpe"`
if [ $nrpe -eq 2 ]
then
  echo "inagios_client install finished"
else
  echo "some error"
fi
