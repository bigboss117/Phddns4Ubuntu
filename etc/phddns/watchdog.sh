#!/bin/bash

tag="false"
ps aux | grep "phddns -c /etc/phddns/phlinux.conf -[d]" > /tmp/phddns.tmp
while read line
do
  tag="true"
done < /tmp/phddns.tmp
rm -rf /tmp/phddns.tmp

if [ $tag = "true" ]; then
  exit 0
fi

phddns -c /etc/phddns/phlinux.conf -d
