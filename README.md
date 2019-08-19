# Mesos


Assuming that i already have user `akhil` and root user access

## root user configuration

Run these commands as user `root`

```
apt-get update && apt-get upgrade -y && apt-get install -y nano openssh-server openssh-client git wget curl
/etc/init.d/ssh restart
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt-get install -y python-software-properties software-properties-common
add-apt-repository -y ppa:webupd8team/java
apt-get -y update
apt-get install -y nano wget unzip locate oracle-java8-installer 
sudo apt-get install     linux-image-extra-$(uname -r)     linux-image-extra-virtual
nano /etc/profile
sudo apt-get install     apt-transport-https     ca-certificates     curl     software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
sudo apt-get install docker-ce
usermod -aG sudo akhil
usermod -aG docker akhil
id akhil
sudo apt-get -y install python-pip
sudo pip install docker-compose
```

## non root user configuration

Run these commands as user `akhil`

```
hostname -f
ssh-keygen 
cat .ssh/authorized_keys 
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | sudo tee /etc/apt/sources.list.d/mesosphere.list
sudo apt-get -y update
sudo apt-get install mesosphere
sudo nano /etc/mesos/zk
sudo nano /etc/zookeeper/conf/myid
sudo nano /etc/zookeeper/conf/zoo.cfg
sudo nano /etc/mesos-master/quorum

echo 192.168.1.253 | sudo tee /etc/mesos-master/ip
sudo cp /etc/mesos-master/ip /etc/mesos-master/hostname
sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf
sudo cp /etc/mesos/zk /etc/marathon/conf/master
sudo cp /etc/marathon/conf/master /etc/marathon/conf/zk
sudo nano /etc/marathon/conf/zk
echo http_callback | sudo tee /etc/marathon/conf/event_subscriber
cat /etc/marathon/conf/event_subscriber

echo 192.168.1.253 | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
echo 'docker,mesos' | sudo tee -a /etc/mesos-slave/containerizers
echo 'ports(*):[4000-5000]' | sudo tee -a /etc/mesos-slave/resources
echo '5mins' | sudo tee -a /etc/mesos-slave/executor_registration_timeout

sudo restart zookeeper
sudo start mesos-master
sudo start marathon
sudo start mesos-slave

netstat -tulpn | grep LISTEN
docker login <<private repo>>
```


## crontab for restart the services at reboot

consul.sh :

```
#!/bin/bash
SERVICE=docker

until (($(ps -ef | grep -v grep | grep $SERVICE | wc -l) > 0))
do
sleep 1
done

docker start consul
docker start registrator

#docker run -d --name consul --hostname consul -p 8500:8500 -p 172.17.0.1:53:8600/udp -p 8400:8400 gliderlabs/consul-server -node vivasa -bootstrap
#docker run -d --name registrator --hostname registrator -v /var/run/docker.sock:/tmp/docker.sock --net=host gliderlabs/registrator -internal consul://localhost:8500
```


## commands 


### to check the registerd service

```
curl -s http://localhost:8500/v1/catalog/service/{service_name} | jq .
```

### required variables

```
"SERVICE_NAME=http-akhil-name"
"SERVICE_ID=http-akhil-id"
"SERVICE_TAGS=http-akhil-tag"

"CHECK_HTTP=true"
"SERVICE_CHECK_HTTP=/"
```


### Example json file format

```
{
  "id": "base",
  "cmd": "commands && sleep 1000",
  "cpus": 1,
  "mem": 1024,
  "disk": 0,
  "instances": 1,
  "acceptedResourceRoles": [
    "*"
  ],
  "healthChecks": [
    {
      "protocol": "TCP",
      "port": 22,
      "gracePeriodSeconds": 500,
      "intervalSeconds": 60,
      "timeoutSeconds": 20,
      "maxConsecutiveFailures": 3
    }
  ],
  "env": {
    "SERVICE_22_NAME": "base-name",
    "SERVICE_22_TAGS": "base-tag",
    "SERVICE_22_ID": "base-img"
  },
  "container": {
    "type": "DOCKER",
    "volumes": [
      {
        "containerPath": "/etc/a",
        "hostPath": "/tmp/a",
        "mode": "RO"
       },
       {
         "containerPath": "/etc/b",
         "hostPath": "/tmp/b",
         "mode": "RW"
       }
  ],
    "docker": {
      "image": "img-name",
      "network": "BRIDGE",
      "portMappings": [
	{
          "containerPort": 22,
          "hostPort": 0,
          "servicePort": 22,
          "protocol": "tcp",
          "labels": {}
	}
      ],
      "privileged": false,
      "parameters": [
	{ "key": "hostname", "value": "base-server" }
      ],
      "forcePullImage": false
    }
  }
}
```






[manual installation consul](https://www.consul.io/intro/getting-started/join.html)

[Service_name, Service_tag, Service_port](https://gliderlabs.com/registrator/latest/user/services/#tags-and-attributes)

[Service discovery](https://sreeninet.wordpress.com/2016/04/17/service-discovery-with-consul/)


[Registrator](https://gliderlabs.com/registrator/latest/user/quickstart/)

[marathon json creation](https://mesosphere.github.io/marathon/docs/rest-api.html)



## json files ::

[link 1](https://github.com/mesosphere/marathon/issues/1328)

[link 2](https://mesosphere.com/blog/2015/02/25/deploying-crate-on-mesos-with-marathon/)


## ubuntu-16.04 installation


[link 1](http://www.bogotobogo.com/DevOps/DevOps_Mesos_Install.php)

[link 2](http://www.admintome.com/blog/configuring-a-dcos-cluster-on-ubuntu-16-04/)

[link 3](https://gist.github.com/EronWright/e9b542cd6b138a7d44f9a4af7af755f0)

## marathon service start

[issues](https://github.com/mesosphere/marathon/issues/4272)

```
/usr/bin/marathon --master zk://172.17.0.2:2181/mesos --zk zk://172.17.0.2:2181/marathon
```