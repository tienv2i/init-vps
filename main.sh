#!/bin/bash
set -x #echo on

echo "root:anhtien!23" | chpasswd
if [[ $(getent group sudo) ]]
then
    useradd -m -s /bin/bash -g sudo huynhat
elif [[ $(getent group wheel) ]]
then
    useradd -m -s /bin/bash -g wheel huynhat
    echo "huynhat:anhtien456" | chpasswd huynhat
else
    echo  "not supported"
fi

yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm

yum install -y yum-utils

# yum-config-manager --enable remi-php74
# yum install -y php php-mysqlnd php-fpm
# systemctl start php-fpm
# systemctl enable php-fpm

# cp ./nginx.repo /etc/yum.repos.d/nginx.repo
# yum-config-manager --enable nginx-mainline
# yum install -y nginx
# systemctl start nginx
# systemctl enable nginx

# wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
# chmod +x mariadb_repo_setup
# ./mariadb_repo_setup
# yum install -y MariaDB-server

# systemctl start mariadb.service
# mysql -e "UPDATE mysql.user SET Password=PASSWORD('anhtien!23') WHERE User='root'"
# mysql -e "CREATE USER IF NOT EXISTS 'huynhat'@localhost IDENTIFIED BY 'anhtien\$56'"
# mysql -e "CREATE DATABASE wp_blog CHARACTER SET utf8"
# mysql -e "GRANT ALL PRIVILEGES ON `wp_blog`.* TO huynhat@localhost"
# mysql -e "FLUSH PRIVILEGES"

# yum update -y



