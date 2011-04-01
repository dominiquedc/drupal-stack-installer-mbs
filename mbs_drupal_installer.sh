#!/bin/bash

color_echo()
{
	text_reverse_bold="$(tput rev) $(tput bold)"
	text_normal="$(tput sgr0)"
	
	echo "${text_reverse_bold}$*${text_normal}"
}

if [ $UID != 0 ]
then
	echo "This script must be run by root".
	exit 1
fi

if [ $# != 3 ]
then
	echo "Usage  : $0 drupal_instance_name mysql_existing_power_user mysql_power_user_password"
	echo "Example: $0 mywebsite root \"\""
	echo "Example: $0 mywebsite mysqlpoweruser secretpassword"
	exit 2
fi

home_dir=$(dirname $0)
bin_dir=$home_dir/bin

drupal_instance_name=$1
mysql_existing_power_user=$2
mysql_power_user_password=$3


color_echo "Starting Drupal install..."

color_echo "Installing Debian/Ubuntu packages..."
apt-get --yes install apache2 php5 php-pear php5-dev php5-gd mysql-server-5.0 php5-mysql mysql-client wget curl

color_echo "Setting up the Apache mod_rewrite for Drupal clean urls..."
a2enmod rewrite

color_echo "Setting up the Apache mod_expires for Apache Cache-Control directive..."
a2enmod expires

color_echo "Setting up the Apache mod_deflate to save bandwidth..."
a2enmod deflate
sed -i 's|DEFLATE text/html text/plain text/xml|DEFLATE text/html text/plain text/xml text/css text/javascript application/x-javascript|' /etc/apache2/mods-available/deflate.conf


color_echo "Adding PEAR package: progress bars on upload..."
pecl install uploadprogress
sed -i '/; extension_dir directive above/ a\
extension=uploadprogress.so' /etc/php5/apache2/php.ini

color_echo "Installing APC php opcode cache..."
pecl install apc
sed -i '/; extension_dir directive above/ a\
extension=apc.so' /etc/php5/apache2/php.ini


#sed -i 's/query_cache_limit       = 1M/query_cache_limit       = 1M\
#query_cache_type        = 1/' /etc/mysql/my.cnf
#echo "Reloading mysql..."
#/etc/init.d/mysql force-reload

color_echo "Reloading Apache..."
/etc/init.d/apache2 force-reload

drush_extract_dir=/opt
drush_install_dir=$drush_extract_dir/drush
color_echo "Installing drush in $drush_install_dir ..."
resources_dir=$home_dir/resources
tar xvf $resources_dir/drush-6.x-3.3.tar.gz -C $drush_extract_dir
cp $resources_dir/Console_Table-1.1.3/Table.php $drush_install_dir/includes/table.inc

#Installing drush make
drush_make_extract_dir=~/.drush
mkdir $drush_make_extract_dir
tar xvf $resources_dir/drush_make-6.x-2.2.tar.gz -C $drush_make_extract_dir

color_echo "Creating the MySQL database for drupal on localhost ..."
$bin_dir/create_database.sh $drupal_instance_name $mysql_existing_power_user $mysql_power_user_password

drupal_path="/var/www/$drupal_instance_name"
color_echo "Installing drupal in $drupal_path ..."

color_echo "Executing make file..."
/opt/drush/drush make ./multimediabs.make $drupal_path

color_echo "Creating additional Drupal directories and files..."
mkdir $drupal_path/profiles/multimediabs
mkdir $drupal_path/sites/all/themes
mkdir $drupal_path/sites/all/modules/custom
mkdir $drupal_path/sites/all/modules/contrib_patched
touch $drupal_path/sites/all/modules/contrib_patched/patches.txt
mkdir $drupal_path/sites/default/files
mkdir $drupal_path/sites/default/tmp

color_echo "Copying Drupal profile and installer translation files..."
cp ./multimediabs.profile $drupal_path/profiles/multimediabs/
cp -R $resources_dir/translations $drupal_path/profiles/multimediabs/

color_echo "Copying and completing the Drupal settings file..."
cp $drupal_path/sites/default/default.settings.php $drupal_path/sites/default/settings.php
cat $resources_dir/settings_snippet.php >> $drupal_path/sites/default/settings.php

color_echo "Copying jquery.ui to module folder..." 
cp -R $resources_dir/jquery.ui $drupal_path/sites/all/modules/contrib/jquery_ui/jquery.ui

color_echo "Setting the work files and directories as writable..." 
chmod 777 $drupal_path/sites/default/files
chmod 777 $drupal_path/sites/default/tmp
chmod 777 $drupal_path/sites/default/settings.php

color_echo "Copying the drush config file..."
cp  $resources_dir/drushrc.php $drupal_path/

color_echo "Restarting apache..."
apachectl restart

#color_echo "Installing xhprof"

#pecl download xhprof-0.9.2
#tar -xvf xhprof-0.9.2.tgz -C /var/tmp
#cd /var/tmp/xhprof-0.9.2/extension
#phpize
#./configure
#make
#make install
#make test

#cp -R /build/buildd/php5-5.3.3/pear-build-download/xhprof-0.9.2/xhprof_html /var/www/xhprof
#ln -s /build/buildd/php5-5.3.3/pear-build-download/xhprof-0.9.2/xhprof_html /var/www/xhprof
#mkdir /var/tmp/xhprof
#chmod 777 /var/tmp/xhprof

color_echo "*) creating an Apache virtual host for $drupal_instance_name with path $drupal_path"
cp $resources_dir/vhost /etc/apache2/sites-available/
sed -i "s/multimediabs/$drupal_instance_name/g" /etc/apache2/sites-available/$drupal_instance_name

color_echo
color_echo "To complete the installation you must:"
color_echo
color_echo '*) add the drush command to the PATH:'
color_echo "  export PATH=$drush_install_dir:\$PATH"
color_echo
color_echo '*) Change your error settings in php.ini to : error_reporting = E_ALL & ~E_DEPRECATED & ~E_NOTICE'
color_echo
color_echo "*) Create an entry in /etc/hosts : 127.0.0.1      $drupal_instance_name"
color_echo
color_echo "*) Update the virtual host file /etc/apache2/sites-available/$drupal_instance_name"
color_echo "create a symlink ln -s /etc/apache2/sites-available/$drupal_instance_name /etc/apache2/sites-enabled/$drupal_instance_name"
color_echo "restart apache with : sudo apachectl restart"
color_echo
color_echo "Open your browser, go to http://$drupal_instance_name and start the 'multimediabs' pressflow install profile"
color_echo
color_echo "You can then add code and modules in the Drupal instance directory in $drupal_path ."
color_echo
color_echo "Add this to php.ini to make xhprof run extension=xhprof.so and xhprof.output_dir=\"/var/tmp/xhprof\" and restart server"

