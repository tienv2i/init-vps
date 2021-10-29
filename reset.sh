#!/usr/bin/env bash
#userdel huynhat
#rm -rf /home/huynhat

systemctl stop nginx
systemctl stop php-fpm
systemctl stop mariadb

yum remove -y php php-* nginx mariadb* epel-release remi-release certbot python2-cerbot-*


rm -f /etc/yum.repos.d/remi-*
rm -f /etc/yum.repos.d/epel-*
rm -f /etc/yum.repos.d/nginx-*
rm -f /etc/yum.repos.d/mariadb*
rm -rf /var/www/wp_blog


cd /usr/local/share/vim/src
make uninstall
cd /usr/local/share
rm -rf /usr/local/share/vim
rm -f /home/huynhat/.vimrc
rm -rf /home/huynhat/.vim

yum remove -y python3 ncurses ncurses-devel
yum groups remove -y "Development Tools"