#!/bin/bash


if [ $UID != 0 ]
then
	echo "This script must be run by root".
	exit 1
else
	echo "Starting Drupal install..."
fi

if [ $# != 3 ]
then
	echo "Usage  : $0 mysql_database_to_create mysql_existing_power_user mysql_power_user_password"
	echo "Example: $0 mywebsite root \"\""
	echo "Example: $0 mywebsite mysqlpoweruser secretpassword"
	exit 2
fi

home_dir=$(dirname $0)
bin_dir=$home_dir/bin

mysql_database_to_create=$1
mysql_existing_power_user=$2
mysql_power_user_password=$3


echo "Installing Debian/Ubuntu packages..."
apt-get --yes install apache2 php5 php-pear php5-dev php5-gd mysql-server-5.0 php5-mysql mysql-client wget curl

echo "Setting up the Apache mod_rewrite for Drupal clean urls..."
a2enmod rewrite

echo "Setting up the Apache mod_expires for Apache Cache-Control directive..."
a2enmod expires

echo "Setting up the Apache mod_deflate to save bandwidth..."
a2enmod deflate
sed -i 's|DEFLATE text/html text/plain text/xml|DEFLATE text/html text/plain text/xml text/css text/javascript application/x-javascript|' /etc/apache2/mods-available/deflate.conf


echo "Adding PEAR package: progress bars on upload..."
pecl install uploadprogress
sed -i '/; extension_dir directive above/ a\
extension=uploadprogress.so' /etc/php5/apache2/php.ini

echo "Installing APC php opcode cache..."
pecl install apc
sed -i '/; extension_dir directive above/ a\
extension=apc.so' /etc/php5/apache2/php.ini


#sed -i 's/query_cache_limit       = 1M/query_cache_limit       = 1M\
#query_cache_type        = 1/' /etc/mysql/my.cnf
#echo "Reloading mysql..."
#/etc/init.d/mysql force-reload

echo "Reloading Apache..."
/etc/init.d/apache2 force-reload

drush_extract_dir=/opt
drush_install_dir=$drush_extract_dir/drush
echo "Installing drush in $drush_install_dir ..."
resources_dir=$home_dir/resources
tar xvf $resources_dir/drush-6.x-3.3.tar.gz -C $drush_extract_dir
cp $resources_dir/Console_Table-1.1.3/Table.php $drush_install_dir/includes/table.inc

#Installing drush make
drush_make_extract_dir=~/.drush
mkdir $drush_make_extract_dir
tar xvf $resources_dir/drush_make-6.x-2.2.tar.gz -C $drush_make_extract_dir

echo "Creating the MySQL database for drupal on localhost ..."
$bin_dir/create_database.sh $mysql_database_to_create $mysql_existing_power_user $mysql_power_user_password

echo "Installing drupal..."
drupal_path="/var/www/multimediabs"

#Execute make file
/opt/drush/drush make ./multimediabs.make $drupal_path

#Configure folders and files
mkdir $drupal_path/profiles/multimediabs
mkdir $drupal_path/sites/all/themes
mkdir $drupal_path/sites/all/modules/custom
mkdir $drupal_path/sites/all/modules/contrib_patched
touch $drupal_path/sites/all/modules/contrib_patched/patches.txt
mkdir $drupal_path/sites/default/files
mkdir $drupal_path/sites/default/tmp

#Copy profile + installer translation files
cp ./multimediabs.profile $drupal_path/profiles/multimediabs/
cp -R $resources_dir/translations $drupal_path/profiles/multimediabs/

#Copy and complete the settings file
cp $drupal_path/sites/default/default.settings.php $drupal_path/sites/default/settings.php
cat $resources_dir/settings_snippet.php >> $drupal_path/sites/default/settings.php

#Les droits
chmod 777 $drupal_path/sites/default/files
chmod 777 $drupal_path/sites/default/tmp
chmod 777 $drupal_path/sites/default/settings.php

#drush config file
cp  $resources_dir/drushrc.php $drupal_path/

#restart apache
apachectl restart

echo "To complete the installation you must:"
echo
echo '*) add the drush command to the PATH:'
echo "  export PATH=$drush_install_dir:\$PATH"
echo
echo '*) Change your error settings in php.ini to : error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE'
echo
echo '*) Create an entry in /etc/hosts : 127.0.0.1      multimediabs'
echo
echo "\*) create a virtual host in /ect/apache2/sites-available for multimediabs with path $drupal_path, use the template in $resources_dir/vhost"
echo "create a symlink ln -s /ect/apache2/sites-available/multimediabs /ect/apache2/sites-enabled/multimediabs"
echo "restart apache with : sudo apachectl restart"
echo
echo "Open your browser and and go to http://multimediabs and start the multimediabs pressflow install profile" 
