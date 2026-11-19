#!/bin/bash
dnf install -y wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
systemctl enable --now mariadb httpd
until mysqladmin ping --silent; do
  sleep 2
done
mysql -e "CREATE DATABASE ${db_name} ;CREATE USER '${db_username}'@'localhost' IDENTIFIED BY '${db_password}'; GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_username}'@'localhost'; FLUSH PRIVILEGES;"
cp wordpress/wp-config-sample.php wordpress/wp-config.php
sed -i "s/database_name_here/${db_name}/g" wordpress/wp-config.php
sed -i "s/username_here/${db_username}/g" wordpress/wp-config.php
sed -i "s/password_here/${db_password}/g" wordpress/wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ > salts.txt
sed -i '/put your unique phrase here/d' wordpress/wp-config.php
sed -i '/DB_COLLATE/r salts.txt' wordpress/wp-config.php
cp -r wordpress/* /var/www/html/
chown -R apache:apache /var/www/html/te