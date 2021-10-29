#!/usr/bin/env bash
#userdel huynhat
#rm -rf /home/huynhat

systemctl stop nginx
systemctl stop php-fpm
systemctl stop mariadb

yum autoremove -y php php-* nginx mariadb* epel-release remi-release certbot python2-cerbot-*


rm -f /etc/yum.repos.d/remi-*
rm -f /etc/yum.repos.d/epel-*
rm -f /etc/yum.repos.d/nginx-*
rm -f /etc/yum.repos.d/mariadb*
rm -rf /var/www/wp_blog