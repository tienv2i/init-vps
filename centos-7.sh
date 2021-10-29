#!/bin/bash
echo "root:anhtien!23" | chpasswd
if [[ $(getent group sudo) ]]
then
    useradd -m -s /bin/bash -g sudo huynhat
elif [[ $(getent group wheel) ]]
then
    useradd -m -s /bin/bash -g wheel huynhat
    echo "huynhat:anhtien456" | chpasswd huynhat
    yum install -y epel-release
    cd /tmp
    wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
    rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm
    yum install -y yum-utils
    yum-config-manager --enable remi-php74
    yum update -y
else
    echo  "not supported"
fi
