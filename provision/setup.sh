#!/usr/bin/env bash

# Use single quotes instead of double quotes to make it work with special-character passwords
PASSWORD='fas+Horse14'
PROJECTFOLDER='example'
DATABASE='example'

echo '--------------- Upgrade Libraries ---------------'
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update
sudo apt-get -y upgrade

echo '--------------- Install NGINX ---------------'
#install nginx
sudo add-apt-repository -y ppa:nginx/stable
sudo apt-get update
sudo apt-get -y install nginx
sudo apt-get -y install fcgiwrap

echo '--------------- Install PHP & PHP Libraries ---------------'
#intall php-fpm
sudo apt-get -y install php-fpm php-mysql php7.0-zip php-curl php-mbstring php-gd php-imagick php-xml

echo '--------------- Install MySQL ---------------'
# install mysql and give password to installer
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${PASSWORD}"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${PASSWORD}"
sudo apt-get -y install mysql-server

mysql -uroot -p${PASSWORD} <<MYSQL_SCRIPT
CREATE DATABASE $DATABASE;
CREATE USER 'dev'@'localhost' IDENTIFIED BY '$PASSWORD';
GRANT ALL PRIVILEGES ON $DATABASE.* TO 'dev'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo '--------------- Add VHosts---------------'
#copy the conf files
sudo cp /vagrant/provision/nginx/conf /etc/nginx/sites-available/$PROJECTFOLDER
sudo chmod 644 /etc/nginx/sites-available/cba.vg.blueearth.net

#create symlink to sites-enabled
sudo ln -s /etc/nginx/sites-available/$PROJECTFOLDER /etc/nginx/sites-enabled/$PROJECTFOLDER

# restart nginx/php7
sudo service nginx restart
sudo service php7.0-fpm restart

#install x-debug
sudo apt-get -y install php-xdebug
sudo cp /vagrant/provision/php/zzz_xdebug.ini /etc/php/7.0/mods-available/zzz_xdebug.ini
sudo ln -sf /etc/php/7.0/mods-available/zzz_xdebug.ini /etc/php/7.0/fpm/conf.d/20-zzz_xdebug.ini

echo '--------------- Composer Install and Update ---------------'
# install Composer
curl -s https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer

# install composer req
cd /var/www/cba/
composer install

# restart nginx/php7
sudo service nginx restart
sudo service php7.0-fpm restart