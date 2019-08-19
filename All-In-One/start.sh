#!/bin/bash
A=$(tput sgr0)
export TERM=xterm
echo ""
mkdir /var/lib/mesos || echo "file exist"

if [ ! -e /var/lib/mesos/mesos-bootstrapped ]; then
echo "configuring mesos,marathon and zookeeper for first run"

HOST_IP=`ifconfig | grep -A 1 eth0 | tail -1 | cut -d ":" -f 2 | cut -d " " -f 1`
echo "zk://$HOST_IP:2181/mesos" > /etc/mesos/zk
echo "1" > /etc/zookeeper/conf/myid
echo "server.1=$HOST_IP:2888:3888" >> /etc/zookeeper/conf/zoo.cfg
echo "1" > /etc/mesos-master/quorum
echo "$HOST_IP" > /etc/mesos-master/ip
cp /etc/mesos-master/ip /etc/mesos-master/hostname
mkdir -p /etc/marathon/conf
cp /etc/mesos-master/hostname /etc/marathon/conf
cp /etc/mesos/zk /etc/marathon/conf/master
echo "zk://$HOST_IP:2181/marathon" > /etc/marathon/conf/zk
stop mesos-slave
echo manual | sudo tee /etc/init/mesos-slave.override

echo "do not remove this file" > /var/lib/mesos/mesos-bootstrapped

fi

echo ""
echo -e '\E[32m'"###################################### $A"
echo -e '\E[33m'"you need to run mesos slave in this machine by following command... $A"
echo -e '\E[33m'"sudo mesos-agent --master=<<container_IP_ADDRESS>>:5050 --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --containerizers=mesos,docker --ip=<<HOST_IP_ADDRESS>> $A"
echo -e '\E[32m'"###################################### $A"
echo ""
echo ""

chown -R  jenkins:jenkins /var/lib/jenkins
/etc/init.d/jenkins start
/etc/init.d/zookeeper start
mesos-master --zk=zk://$HOST_IP:2181/mesos --quorum=1 --work_dir=/var/lib/mesos --log_dir=/var/log/mesos --ip=$HOST_IP &
/etc/init.d/marathon start
tailf /var/log/jenkins/jenkins.log

