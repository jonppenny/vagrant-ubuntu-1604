#!/usr/bin/env bash

apache_config_file="/etc/apache2/envvars"
apache_vhost_file="/etc/apache2/sites-available/vagrant_vhost.conf"
#php_config_file="/etc/php5/apache2/php.ini"
#xdebug_config_file="/etc/php5/mods-available/xdebug.ini"
mysql_config_file="/etc/mysql/my.cnf"
#default_apache_index="/var/www/html/index.html"

update_go() {
	# Update the server
	apt-get update
	apt-get -y upgrade
}

apache_go() {
	# Install Apache
	apt-get -y install apache2

	sed -i "s/^\(.*\)www-data/\1www-data/g" ${apache_config_file}
	chown -R www-data:www-data /var/log/apache2

	cat << EOF > ${apache_vhost_file}
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        LogLevel debug
        ErrorLog /var/log/apache2/error.log
        CustomLog /var/log/apache2/access.log combined
        <Directory /var/www>
            AllowOverride All
            Require all granted
        </Directory>
</VirtualHost>
EOF

	a2dissite 000-default
	a2ensite vagrant_vhost

	a2enmod rewrite

	service apache2 reload
	update-rc.d apache2 enable
}

php_go() {
	sudo add-apt-repository -y ppa:ondrej/php
	sudo apt-get -y update
	sudo apt-get -y install php7.1 php7.1-common
	sudo apt-get -y install php7.1-curl php7.1-xml php7.1-zip php7.1-gd php7.1-mysql php7.1-mbstring
	service apache2 reload
}

mysql_go() {
	# Install MySQL
	echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
	echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
	apt-get -y install mysql-client mysql-server

	sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" ${mysql_config_file}

	# Allow root access from any host
	echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION" | mysql -u root --password=root
	echo "GRANT PROXY ON ''@'' TO 'root'@'%' WITH GRANT OPTION" | mysql -u root --password=root

	# Create database
	echo "create database wordpress" | mysql -u root --password=root

	# Create user
	echo "create user 'wordpress'@'localhost' identified by 'password'" | mysql -u root --password=root

	# Grant privileges
	echo "grant all privileges on wordpress.* to 'wordpress'@'localhost'" | mysql -u root --password=root

	# Flush
	echo "flush privileges" | mysql -u root --password=root

	service mysql restart
	update-rc.d apache2 enable
}

main() {
	update_go

	if [[ -e /var/lock/vagrant-provision ]]; then
	    cat 1>&2 << EOD
################################################################################
# To re-run full provisioning, delete /var/lock/vagrant-provision and run
#
#    $ vagrant provision
#
# From the host machine
################################################################################
EOD
	    exit
	fi

	apache_go
	php_go
	mysql_go

	touch /var/lock/vagrant-provision
}

main
exit 0