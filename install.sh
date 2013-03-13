#!/bin/bash

account=`whoami`
if [ $account != "root" ]; then
    echo "Error : please use \"root\" account."
    exit 1
fi

sudo service phddns stop >/dev/null 2>/dev/null
if [ -f "/etc/rc0.d/K08phddns" ];then
  sudo rm -rf /etc/rc0.d/K08phddns
fi
if [ -f "/etc/rc1.d/K08phddns" ];then
  sudo rm -rf /etc/rc1.d/K08phddns
fi
if [ -f "/etc/rc2.d/S92phddns" ];then
  sudo rm -rf /etc/rc2.d/S92phddns
fi
if [ -f "/etc/rc3.d/S92phddns" ];then
  sudo rm -rf /etc/rc3.d/S92phddns
fi
if [ -f "/etc/rc4.d/S92phddns" ];then
  sudo rm -rf /etc/rc4.d/S92phddns
fi
if [ -f "/etc/rc5.d/S92phddns" ];then
  sudo rm -rf /etc/rc5.d/S92phddns
fi
if [ -f "/etc/rc6.d/K08phddns" ];then
  sudo rm -rf /etc/rc6.d/K08phddns
fi
if [ -f "/etc/init.d/phddns" ];then
  sudo rm -rf /etc/init.d/phddns
fi
if [ -f "/usr/bin/phddns" ];then
  sudo rm -rf /usr/bin/phddns
fi
if [ -f "/etc/phlinux.conf" ];then
  sudo rm -rf /etc/phlinux.conf
fi
if [ -d "/etc/phddns" ];then
  sudo rm -rf /etc/phddns
fi
if [ -f "/var/log/phddns.log" ];then
  sudo rm -rf /var/log/phddns.log
fi

package="phddns-2.0.5.19225"
user="phddns"

sudo apt-get update && sudo apt-get -y install autoconf automake
tar zxvf "./src/$package.tar.gz" && cd "./$package" && aclocal && autoconf && automake && ./configure && make
cd ..
sudo cp ./$package/src/phddns /usr/bin/phddns
sudo chown root:root /usr/bin/phddns
sudo chmod 755 /usr/bin/phddns
sudo rm -rf ./$package

echo "Start config phddns"
tag="false"
sudo phddns -d

ps aux | grep "phddns -[d]" > /tmp/phddns.tmp
while read line
do
  echo $line >> /tmp/phddns.pid
  tag="true"
done < /tmp/phddns.tmp
rm -rf /tmp/phddns.tmp

if [ $tag = "false" ];then
  echo "Error : config phddns interrupt."
  exit 1
fi

while read line
do
  pid=`echo $line | cut -d " " -f 2`
  sudo kill -9 $pid
done < /tmp/phddns.pid
rm -rf /tmp/phddns.pid
echo "Finish config phddns"

sudo adduser --system --home /nonexistent --shell /bin/bash --no-create-home --disabled-password --disabled-login $user

sudo chown -R $user:nogroup /var/log/phddns.log

if [ ! -d "/etc/phddns" ];then
  mkdir -p /etc/phddns
fi
sudo mv /etc/phlinux.conf /etc/phddns/phlinux.conf
sudo cp ./etc/phddns/* /etc/phddns/
sudo chown -R $user:nogroup /etc/phddns

sudo cp ./etc/init.d/phddns /etc/init.d/phddns
sudo chown -R root:root /etc/init.d/phddns
sudo chmod 700 /etc/init.d/phddns

sudo ln -s /etc/init.d/phddns /etc/rc0.d/K08phddns >/dev/null 2>&1
sudo ln -s /etc/init.d/phddns /etc/rc1.d/K08phddns >/dev/null 2>&1
sudo ln -s /etc/init.d/phddns /etc/rc2.d/S92phddns >/dev/null 2>&1
sudo ln -s /etc/init.d/phddns /etc/rc3.d/S92phddns >/dev/null 2>&1
sudo ln -s /etc/init.d/phddns /etc/rc4.d/S92phddns >/dev/null 2>&1
sudo ln -s /etc/init.d/phddns /etc/rc5.d/S92phddns >/dev/null 2>&1
sudo ln -s /etc/init.d/phddns /etc/rc6.d/K08phddns >/dev/null 2>&1

sudo service phddns start
