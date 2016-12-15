#!/usr/bin/env bash

#Run from ~

#IUS offers an installation script for subscribing to their repository and importing associated GPG keys.
echo "Retrieving the IUS script..."
curl 'https://setup.ius.io/' -o setup-ius.sh

echo "Running the script..."
sudo bash setup-ius.sh

echo "Removing existing nginx installation if any..."
sudo yum -y -q remove nginx

echo "Removing existing PHP packages if any..."
sudo yum -y -q remove php*

echo "Installing nginx..."
sudo yum -y -q install nginx

echo "Installing the new PHP7 packages from IUS..."
sudo yum -y -q install php70u-* --skip-broken

echo "Removing incompatible image magick library..."
sudo yum -y -q remove ImageMagick

echo "Installing composer..."
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/bin/composer

echo "Replacing /etc/php-fpm.conf file..."
sudo mv php-fpm.conf /etc/php-fpm.conf
sudo chown root:root /etc/php-fpm.conf
sudo chmod 0644 /etc/php-fpm.conf

echo "Replacing /etc/php-fpm.d/www.conf file..."
sudo mv www.conf /etc/php-fpm.d/www.conf
sudo chown root:root /etc/php-fpm.d/www.conf
sudo chmod 0644 /etc/php-fpm.d/www.conf

echo "Replacing /etc/nginx/nginx.conf file..."
sudo mv nginx.conf /etc/nginx/nginx.conf
sudo chown root:root /etc/nginx/nginx.conf
sudo chmod 0644 /etc/nginx/nginx.conf

echo "Replacing /etc/nginx/conf.d/default.conf file..."
sudo mv default.conf /etc/nginx/conf.d/default.conf
sudo chown root:root /etc/nginx/conf.d/default.conf
sudo chmod 0644 /etc/nginx/conf.d/default.conf

echo "Replacing /etc/nginx/conf.d/php-fpm.conf file..."
sudo mv conf.d/php-fpm.conf /etc/nginx/conf.d/php-fpm.conf
sudo chown root:root /etc/nginx/conf.d/php-fpm.conf
sudo chmod 0644 /etc/nginx/conf.d/php-fpm.conf

echo "Replacing /etc/nginx/conf.d/proxy.conf file..."
sudo mv proxy.conf /etc/nginx/conf.d/proxy.conf
sudo chown root:root /etc/nginx/conf.d/proxy.conf
sudo chmod 0644 /etc/nginx/conf.d/proxy.conf

echo "Replacing /etc/nginx/default.d/php.conf file..."
sudo mv php.conf /etc/nginx/default.d/php.conf
sudo chown root:root /etc/nginx/default.d/php.conf
sudo chmod 0644 /etc/nginx/default.d/php.conf

echo "Removing /etc/nginx/conf.d/virtual.conf file..."
sudo rm /etc/nginx/conf.d/virtual.conf

echo "Emptying server root directory /var/www ..."
sudo rm -rf /var/www/*

echo "Adding test file..."
sudo mkdir /var/www/web
sudo mv index.php /var/www/web
sudo chown -R www-data:www-data /var/www/

echo "Add nginx user to www-data group..."
sudo usermod -a -G www-data nginx

echo "Make sure nginx user owns /var/run/php-fpm directory...."
sudo chown -R nginx:nginx /var/run/php-fpm

echo "Starting nginx...."
sudo /etc/init.d/nginx start
sudo /etc/init.d/nginx reload
sudo service nginx status

echo "Starting PHP-FPM..."
sudo /etc/init.d/php-fpm start
sudo /etc/init.d/php-fpm reload
sudo service php-fpm status

echo "Make sure nginx always start on server reload..."
sudo chkconfig nginx on

echo "Make sure php-fpm always start on server reload..."
sudo chkconfig php-fpm on

echo "Housekeeping..."
sudo rm setup-ius.sh
sudo rm composer.phar