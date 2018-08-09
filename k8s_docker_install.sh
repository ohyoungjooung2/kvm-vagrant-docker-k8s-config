#!/usr/bin/env bash

DOCKER=`which docker`
#Stable docker version for k8s
STABDV="17.03.2-ce"
if [[ $DOCKER ]]
then
 INSTALLED_DOCKER_VERSION=$($DOCKER -v | awk -F"," '{ print $1 }' | awk '{print $3}' 2> /dev/null)
fi

remove_docker(){
  sudo yum remove -y docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-selinux \
                  docker-engine-selinux \
                  docker-engine
}


repo_setup(){
  sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2 \
  libcgroup  \
  policycoreutils-python \
  libtool-ltdl;

  #When docker-ce.repo not exists
  if [[ ! -e /etc/yum.repo.d/docker-ce.repo ]]
  then
  sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo;
  fi
}

install_docker(){
    #sudo yum -y install docker-ce
    #sudo yum -y install docker-ce-$STABDV
    #sudo setenforce 0
    sudo yum -y --setopt=obsoletes=0 install docker-ce-selinux-17.03.2.ce-1.el7.centos docker-ce-17.03.2.ce-1.el7.centos
    #sudo rpm -Uvh https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-selinux-17.03.2.ce-1.el7.centos.noarch.rpm
    #sudo rpm -Uvh https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-17.03.2.ce-1.el7.centos.x86_64.rpm

}

start_docker(){
    sudo systemctl enable docker
    sudo systemctl start docker
    sleep 1
    sudo docker run hello-world
}

restart_docker(){
    sudo systemctl restart docker
}

docker_install_check(){
 #CHECK=$(rpm -qa | grep -i docker)
 CHECK=$($DOCKER -v 2> /dev/null)
 #declare -a DOCKER_OLD=($CHECK)
 #When STABDV IS NOT SAME AS INSTALLED VERSION, INSTALL DOCKER VERSION OF $STABDV
 if [[ $CHECK && ($STABDV != $INSTALLED_DOCKER_VERSION ) ]]
 then
   repo_setup
   remove_docker
   install_docker
   restart_docker
 elif [[ $STABDV == $INSTALLED_DOCKER_VERSION ]]
 then

   echo -e "Installed docker version for kubernets is compliant with current kubernet. Version is $STABDV == \e[31m $CHECK \e[0m OK!"
 else
   echo "NO docker installed"
   repo_setup
   install_docker
   start_docker
 fi
}


docker_install_check
