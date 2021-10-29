#!/usr/bin/env bash
set -x #echo on

# selinuxenabled
if [[ $? -eq 0 ]]; then 
    setenforce 0
fi

echo "root:anhtien!23" | chpasswd

if [[ $(getent group sudo) ]]; then
    group=sudo
    http_own=www-data
# elif [[ $(getent group wheel) ]]; then
#     group = wheel
else 
    group=wheel
    http_own=nginx
fi

if [[ $(getent passwd huynhat) ]]; then
    useradd -m -s /bin/bash -g $group huynhat
    # usermod -aG $http_own huynhat
    echo "huynhat:anhtien456" | chpasswd
fi
    
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm

yum install -y yum-utils

yum-config-manager --enable remi-php74

yum update -y
yum install -y php php-mysqlnd php-fpm php-common php-mysql php-json php-opcache php-mbstring php-xml php-gd php-curl php-bcmath php-imagick php-pear

systemctl start php-fpm
systemctl enable php-fpm

yum remove nginx -y
rm -rf /etc/yum.repos.d/nginx.repo
cat > /etc/yum.repos.d/nginx.repo <<OEL
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/\$releasever/\$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true
OEL

yum-config-manager --enable nginx-mainline
yum install -y nginx

systemctl start nginx
systemctl enable nginx

if [[ $(getent passwd huynhat) ]]; then
    usermod -aG $http_own huynhat
fi

firewall-cmd --permanent --zone=public --add-service=http --add-service=https 
firewall-cmd --reload

wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
./mariadb_repo_setup
yum install -y MariaDB-server

systemctl start mariadb.service
systemtel enable mariasb.service

# mysql -e "UPDATE mysql.user SET Password=PASSWORD(\'anhtien!23\') WHERE User=\'root\'"
# mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password'"
# mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('new_password')"

mysql -e "CREATE USER IF NOT EXISTS 'huynhat'@localhost IDENTIFIED BY 'anhtien\$56'"
mysql -e "CREATE DATABASE IF NOT EXISTS wp_blog CHARACTER SET utf8"
mysql -e "GRANT ALL PRIVILEGES ON \`wp_blog\`.* TO huynhat@localhost"
mysql -e "FLUSH PRIVILEGES"

mkdir /var/www/wp_blog
wget https://wordpress.org/latest.tar.gz
tar -xzvf latest.tar.gz
mv ./wordpress/* /var/www/wp_blog
chown -R $http_own:$http_own /var/www/wp_blog
chmod -R u=wrx,g=wrx,o=wr /var/www/wp_blog

rm -r /etc/nginx/conf.d/wp_blog.conf
cat > /etc/nginx/conf.d/wp_blog.conf <<OEL
server {
    listen   80;
    server_name  huynhanhtien.com www.huynhanhtien.com;

    root /var/www/wp_blog;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php\$args;
    }

    location ~ \.php\$ {
        fastcgi_pass unix:/var/run/php-fpm/php-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
OEL

nginx -s reload
systemctl restart php-fpm

sed -i 's/^user\s=\sapache$/user = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/^group\s=\sapache$/group = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/^;listen\.owner\s=\snobody$/listen.owner = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/^;listen\.group\s=\snobody$/listen.group = nginx/' /etc/php-fpm.d/www.conf
sed -i 's/^;listen\.mode\s=\s0660$/listen.mode = 0660/' /etc/php-fpm.d/www.conf
sed -i 's/^listen\s=\s[0-9\.\:]*$/listen = \/var\/run\/php-fpm\/php-fpm.sock/' /etc/php-fpm.d/www.conf

systemctl restart php-fpm
systemctl restart nginx

yum install -y certbot python2-certbot-nginx
certbot run -n --nginx --agree-tos -d huynhanhtien.com,www.huynhanhtien.com  -m  tienv2i@gmail.com  --redirect
certbot renew --dry-run

yum install -y python3
yum groups install -y "Development Tools"
yum install -y ncurses ncurses-devel
cd /usr/local/share
git clone https://github.com/vim/vim.git
cd vim/src
./configure --with-features=huge \
--enable-multibyte \
--enable-rubyinterp=yes \
--enable-pythoninterp=yes \
--enable-python3interp=yes \  
--prefix=/usr/local/vim8
make
make install
touch /home/huynhat/.vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -s /home/huynhat/.vimrc /root/.vimrc
ln -sd /home/huynhat/.vim /root/.vim
ln -s /usr/local/bin/vim /usr/bin/vim
cat > /home/huynhat/.vimrc << OEF
call plug#begin('~/.vim/plugged')
    Plug 'sheerun/vim-polyglot'
    Plug 'jiangmiao/auto-pairs'
    Plug 'preservim/nerdtree'

call plug#end()
set nu
syntax on
set incsearch
set hlsearch
set backspace=indent,eol,start
set tabstop=8
set shiftwidth=4
set expandtab
set termwinsize=10x0
set splitbelow
set mouse=a
let g:AutoPairsShortcutToggle = '<C-P>'
nmap <F2> :NERDTreeToggle<CR>
OEF
# vim +PlugInstall
vim +'PlugInstall --sync' +qall &> /dev/null