#!/bin/bash

database_name=$1
mysql_user=$2
mysql_password=$3

mysql_cmd="mysql --protocol=TCP -u $mysql_user"
if [ "$mysql_password" != "" ]
then
	mysql_cmd="$mysql_cmd -p$mysql_password"
fi

$mysql_cmd << EOF

DROP DATABASE IF EXISTS $database_name ;
CREATE DATABASE $database_name ;
CREATE USER $database_name IDENTIFIED BY '$database_name' ;
GRANT ALL ON $database_name.* TO $database_name

EOF

