set -x #echo on

yum install -y epel-release
yum install -y remi-release.noarch
# cd /tmp
# wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
# rpm -Uvh remi-release-7.rpm epel-release-latest-7.noarch.rpm
# yum install -y yum-utils
# yum-config-manager --enable remi-php76
# yum update -y