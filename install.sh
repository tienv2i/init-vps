#!/usr/bin/env bash
set -x #echo on

# selinuxenabled
if [[ $? -eq 0 ]]; then 
    setenforce 0
fi

server_name=tineblog.info
db_username=huynhat
db_password=anhtien!23
db_name=wp_blog

# $1 as username=huynhat, $2 as password=anhtien456, $3 as root_password=anhtien!23
[[ -z "$1" ]] && username="huynhat" || username="$1"
[[ -z "$2" ]] && password="anhtien456" || username="$2"
[[ -z "$3" ]] && root_password="anhtien!23" || root_password="$3"

# check admin group wether sudo or wheel
[[ -n $(getent group "sudo") ]] && group="sudo" || group="wheel"

# change root password
echo "root:$root_password" | chpasswd

# create admin user
[[ -z $(getent passwd $username) ]] && useradd -m -s /bin/bash -g $group
echo "$username:$password" | chpasswd # change admin password after created
    
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y https://rpms.remirepo.net/enterprise/remi-release-7.rpm

yum install -y yum-utils

yum-config-manager --enable remi-php74

yum update -y
yum install -y php php-mysqlnd php-fpm php-common php-mysql php-json php-opcache php-mbstring php-xml php-gd php-curl php-bcmath php-imagick php-pear php-zip

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

if [[ $(getent passwd $username) ]]; then
    usermod -aG $http_own $username
fi

firewall-cmd --permanent --zone=public --add-service=http --add-service=https 
firewall-cmd --reload

wget https://downloads.mariadb.com/MariaDB/mariadb_repo_setup
chmod +x mariadb_repo_setup
./mariadb_repo_setup
yum install -y MariaDB-server

systemctl start mariadb.service
systemctl enable mariadb.service

# mysql -e "UPDATE mysql.user SET Password=PASSWORD(\'anhtien!23\') WHERE User=\'root\'"
# mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password'"
# mysql -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('new_password')"

mysql -e "CREATE USER IF NOT EXISTS '$db_username'@localhost IDENTIFIED BY '$db_password'"
mysql -e "CREATE DATABASE IF NOT EXISTS \`$db_name\` CHARACTER SET utf8"
mysql -e "GRANT ALL PRIVILEGES ON \`db_name\`.* TO $db_username@localhost"
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
    # listen 443 ssl;

    server_name  $server_name www.$server_name;

    client_max_body_size 100M;

    root /var/www/wp_blog;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php\$is_args\$args;
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

sed -iE 's/^[;\s]*user\s*=.*$/user = nginx/' /etc/php-fpm.d/www.conf
sed -iE 's/^[;\s]*group\s*=.*$/group = nginx/' /etc/php-fpm.d/www.conf
sed -iE 's/^[;\s]*listen\.owner\s*=.*$/listen.owner = nginx/' /etc/php-fpm.d/www.conf
sed -iE 's/^[;\s]*listen\.group\s*=.*$/listen.group = nginx/' /etc/php-fpm.d/www.conf
sed -iE 's/^[;\s]*listen\.mode\s*=.*$/listen.mode = 0660/' /etc/php-fpm.d/www.conf
sed -iE 's/^[;\s]*listen\s*=.*$/listen = \/var\/run\/php-fpm\/php-fpm.sock/' /etc/php-fpm.d/www.conf
sed -iE 's/^[;\s]*upload_max_filesize\s*=.*$/upload_max_filesize = 50M/' /etc/php.ini
sed -iE 's/^[;\s]*post_max_size\s*=.*$/upload_max_filesize = 55M/' /etc/php.ini


systemctl restart php-fpm
systemctl restart nginx

yum install -y certbot python2-certbot-nginx
certbot run -n --nginx --agree-tos -d $server_name,www.$server_name  -m  tienv2i@gmail.com  --redirect
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
touch /home/$username/.vimrc
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
ln -s /home/$username/.vimrc /root/.vimrc
ln -sd /home/$username/.vim /root/.vim
ln -s /usr/local/bin/vim /usr/bin/vim
cat > /home/$username/.vimrc << OEF
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