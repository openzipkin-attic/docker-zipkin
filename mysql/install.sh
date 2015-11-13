#!/bin/sh
set -eux

echo "*** Installing MySQL"
apk add --update mysql mysql-client
mysql_install_db --user=mysql --basedir=/usr/ --datadir=/mysql/data --force
chown -R mysql /mysql
# change default run path to the work dir
sed -i -e"s~/run/mysqld~/mysql~g" -e 's/#.*$//' -e '/^$/d' /etc/mysql/my.cnf

echo "*** Starting MySQL"
mysqld --user=mysql --basedir=/usr/ --datadir=/mysql/data &

timeout=300
while [[ "$timeout" -gt 0 ]] && ! mysql --user=mysql --protocol=socket -uroot -e 'SELECT 1' >/dev/null 2>/dev/null; do
    echo "Waiting ${timeout} seconds for mysql to come up"
    sleep 2
    timeout=$(($timeout - 2))
done

echo "*** Importing Schema"
curl https://raw.githubusercontent.com/openzipkin/zipkin/$ZIPKIN_VERSION/zipkin-anormdb/src/main/resources/mysql.sql > /mysql/zipkin.sql
mysql --verbose --user=mysql --protocol=socket -uroot <<-EOSQL
USE mysql ;

DELETE FROM mysql.user ;
DROP DATABASE IF EXISTS test ;

SET GLOBAL innodb_file_format=Barracuda ;
CREATE DATABASE zipkin ;

USE zipkin;
SOURCE /mysql/zipkin.sql ;

GRANT SELECT, INSERT, UPDATE, DELETE ON zipkin.* TO zipkin@'%' IDENTIFIED BY 'zipkin' WITH GRANT OPTION ;
FLUSH PRIVILEGES ;
EOSQL

echo "*** Stopping MySQL"
pkill -f mysqld

echo "*** Cleaning Up"
apk del mysql-client --purge

echo "*** Image build complete"
