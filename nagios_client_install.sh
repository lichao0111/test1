#!/bin/bash
#nagios agent install
#���Ƚ�nrpe-2.13.tar.gz ��nagios-plugins-1.4.13.tar.gz �Լ���ؽű�check_disk_zzy�ַ���ÿ̨������/root Ŀ¼��
#�ٽ��˽ű��ַ���ȥ��ִ��,�ڼ�ض˵�/usr/local/nagios/etc/objects/servers Ŀ¼�£���Ӷ�Ӧ�ı���ض˵������ļ�

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

#�޸ı���ض˵������ļ�����ӱ���ض�IP�ͼ�ص���Ŀ
sed -i 's@allowed_hosts=127.0.0.1@allowed_hosts=127.0.0.1,117.28.243.18,117.28.242.133@' /usr/local/nagios/etc/nrpe.cfg
echo -e 'command[check_disk_zzy]=/usr/local/nagios/libexec/check_disk_zzy -w 70 -c 80' >> /usr/local/nagios/etc/nrpe.cfg
echo -e 'command[check_salt]=/usr/local/nagios/libexec/check_procs -w 1:1 -C salt-minion' >> /usr/local/nagios/etc/nrpe.cfg

mv /root/check_disk_zzy /usr/local/nagios/libexec/ -f
chmod 755 /usr/local/nagios/libexec/*

/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d
echo '/usr/local/nagios/bin/nrpe -c /usr/local/nagios/etc/nrpe.cfg -d' >> /etc/rc.local

#��ӷ���ǽ
iptables -I INPUT -p tcp -m multiport --dports 5666 -j ACCEPT
service iptables save &>/dev/null

nrpe=`ps -ef | grep -c "nrpe"`
if [ $nrpe -eq 2 ]
then
  echo "inagios_client install finished"
else
  echo "some error"
fi
