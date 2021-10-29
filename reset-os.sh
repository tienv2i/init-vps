#userdel huynhat
#rm -rf /home/huynhat

yum autoremove -y php php-* nginx mariadb mariadb-*

rm -f /etc/yum.repos.d/remi-*
rm -f /etc/yum.repos.d/epel-*
rm -f /etc/yum.repos.d/nginx-*
rm -f /etc/yum.repos.d/mariadb*
