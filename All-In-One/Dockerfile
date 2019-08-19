from akhilrajmailbox/ubuntu:14.04
maintainer Akhil Raj <akhilrajmailbox@gmail.com>

run apt-get update && apt-get upgrade -y \
        && apt-get install -y nano apt-utils net-tools dnsutils wget unzip openssh-server openssh-client git \
        software-properties-common \
        --no-install-recommends \
        && add-apt-repository ppa:webupd8team/java -y \
        && apt-get update -y \
        && echo debconf shared/accepted-oracle-license-v1-1 select true | \
        debconf-set-selections \
        && echo debconf shared/accepted-oracle-license-v1-1 seen true | \
        debconf-set-selections \
        && apt-get install oracle-java8-installer -y \
        --no-install-recommends \
        && apt install oracle-java8-set-default


run apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
run sh -c 'echo "deb http://repos.mesosphere.io/ubuntu trusty main" | tee /etc/apt/sources.list.d/mesosphere.list'
run apt-get -y update && apt-get install mesosphere -y


run wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | apt-key add - \
        && sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

run apt-get update && apt-get install jenkins sudo -y
run usermod -aG sudo jenkins
run sh -c 'echo "jenkins ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
run sed -i "s|HTTP_PORT=8080|HTTP_PORT=6060|g" /etc/default/jenkins

expose 5050 6060 8080
env JAVA_HOME /usr/lib/jvm/java-8-oracle
env JAVA_OPTS "-Xmx4096m"
env PATH $PATH:$JAVA_HOME/bin
add start.sh /root/start.sh
run chmod 777 /root/start.sh

entrypoint "/root/start.sh"
#entrypoint chown -R  jenkins:jenkins /var/lib/jenkins && /etc/init.d/jenkins start && tailf /var/log/jenkins/jenkins.log
