#!/bin/bash
#--------------------------------參數定義--------------------------------
mysql_datadir="/var/lib/mysql"
mysql_socket="/var/lib/mysql/mysql.sock"
mysql_log_error="/var/log/mysqld.log"
mysql_pid_file="/var/run/mysqld/mysqld.pid"

mysql_character="utf8mb4";
mysql_collation="utf8mb4_unicode_ci";

mysql_password="";
root_remote="n";

#--------------------------------接收參數--------------------------------
echo "Enter mysql5.7 root password."
read mysql_password
if [ -z "$mysql_password" ]; then
	echo "mysql password is not empty";
	exit 1;
fi

#echo "Enter the mysql5.7 installation directory.(default ${mysql_dir})"
#read mysql_dir_temp
#if [ -n "$mysql_dir_temp" ]; then 
#	mysql_dir=${mysql_dir_temp};
#fi
#if [ ${mysql_dir: -1} = "/" ]; then
#	mysql_dir=${mysql_dir%?}
#fi

echo "Whether mysql root enables remote access ?(y/n,default n)"
read root_remote
if [ "${root_remote}" != "y" ]; then
	root_remote="n"
fi

#mysql_datadir="$mysql_dir/data"
#mysql_socket="$mysql_dir/mysql.sock"
#mysql_log_error="$mysql_dir/mysqld.log"
#mysql_pid_file="$mysql_dir/mysqld.pid"

printf "\033[44;36m%-30s = %s \033[0m\n" "Mysql root password" ${mysql_password};
#printf "\033[44;36m%-30s = %s \033[0m\n" "my.cnf datadir" ${mysql_datadir};
#printf "\033[44;36m%-30s = %s \033[0m\n" "my.cnf socket" ${mysql_socket};
#printf "\033[44;36m%-30s = %s \033[0m\n" "my.cnf log-error" ${mysql_log_error};
#printf "\033[44;36m%-30s = %s \033[0m\n" "my.cnf pid-file" ${mysql_pid_file};
printf "\033[44;36m%-30s = %s \033[0m\n" "Root remote access" ${root_remote};

echo "confirm?(y/n,default n)"
read confirm
if [ -z "$confirm" ] || [ ${confirm} != "y" ]; then
	echo "exit";
	exit 1;
fi

if [ ! -d "./workdir" ]; then
mkdir ./workdir
fi
cd workdir

#--------------------------------設置my.cnf--------------------------------
touch my.cnf
echo "" > my.cnf
echo "[mysqld]" 										>> my.cnf
echo "datadir=${mysql_datadir}" 						>> my.cnf
echo "socket=${mysql_socket}" 							>> my.cnf
echo "symbolic-links=0" 								>> my.cnf
echo "log-error=${mysql_log_error}" 					>> my.cnf
echo "pid-file=${mysql_pid_file}" 						>> my.cnf
echo "character-set-server    = ${mysql_character}" 	>> my.cnf
echo "collation-server        = ${mysql_collation}" 	>> my.cnf
echo "max_allowed_packet      = 64M" 					>> my.cnf
echo "[client]" 										>> my.cnf
echo "default-character-set   = ${mysql_character}" 	>> my.cnf
echo "[mysql]" 											>> my.cnf
echo "default-character-set   = ${mysql_character}" 	>> my.cnf

#--------------------------------安裝mysql--------------------------------
yum -y install wget
wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
yum -y localinstall mysql57-community-release-el7-11.noarch.rpm
yum -y install mysql-community-server

if [ ! -d "/etc/my.cnf" ]; then
mv /etc/my.cnf /etc/my.cnf.bak
fi
mv ./my.cnf /etc/my.cnf
#啟動
systemctl start mysqld.service

#--------------------------------修改密碼--------------------------------
#截取password字符行
passwordTemp=`grep 'temporary password' ${mysql_log_error}`
#截取password
passwordTemp=${passwordTemp##*:}
#左右去空格
passwordTemp=`echo $passwordTemp | sed -e 's/^[ \t]*//g' -e 's/[ \t]*$//g'`
echo "mysql temp password=${passwordTemp}"
mysql -uroot -p${passwordTemp} --connect-expired-password -e "set global validate_password_policy=0;set global validate_password_length=1;SET PASSWORD = PASSWORD('${mysql_password}');flush privileges;"

#--------------------------------開啟遠程訪問--------------------------------
if [ "${root_remote}" = "y" ]; then
	mysql -uroot -p${mysql_password} --connect-expired-password -e "use mysql;GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${mysql_password}';flush privileges;"
fi