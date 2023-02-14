#!/bin/sh

MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-1234567890}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-123456}
MAGIC3_INSTALL_DEF_PATH="include/install/installDef.php"

# init nginx
if [ ! -d "/var/tmp/nginx/client_body" ]; then
  mkdir -p /run/nginx /var/tmp/nginx/client_body
  chown nginx:nginx -R /run/nginx /var/tmp/nginx/
fi

# init mysql
if [ ! -f "/run/mysqld/.init" ]; then
  [[ "$MYSQL_USER" = "root" ]] && echo "Please set MYSQL_USER other than root" && exit 1

  SQL=$(mktemp)

  mkdir -p /run/mysqld /var/lib/mysql
  chown mysql:mysql -R /run/mysqld /var/lib/mysql
  sed -i -e 's/skip-networking/skip-networking=0/' /etc/my.cnf.d/mariadb-server.cnf
  mysql_install_db --user=mysql --datadir=/var/lib/mysql

  if [ -n "$MYSQL_DATABASE" ]; then
    #echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" >> $SQL
    echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" >> $SQL
  fi

  MYSQL_DATABASE=${MYSQL_DATABASE:-*}

  if [ -n "MYSQL_USER" ]; then
    echo "GRANT ALL ON $MYSQL_DATABASE.* to '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $SQL
    echo "GRANT ALL ON $MYSQL_DATABASE.* to '$MYSQL_USER'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $SQL
    echo "GRANT ALL ON $MYSQL_DATABASE.* to '$MYSQL_USER'@'::1' IDENTIFIED BY '$MYSQL_PASSWORD';" >> $SQL
  fi

  echo "ALTER user 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';" >> $SQL
  echo "DELETE FROM mysql.user WHERE User = '' OR Password = '';" >> $SQL
  echo "FLUSH PRIVILEGES;" >> $SQL
  cat "$SQL" | mysqld --user=mysql --bootstrap --silent-startup --skip-grant-tables=FALSE

  rm -rf ~/.mysql_history ~/.ash_history $SQL
  touch /run/mysqld/.init
fi

# Download Magic3 source
cd /var/www/html
git clone --depth 1 https://github.com/magic3org/magic3.git
chown -R www-data:www-data magic3

# Setup Magic3
cat <<_EOT_ > magic3/${MAGIC3_INSTALL_DEF_PATH}
<?php
define('M3_INSTALL_ADMIN_SERVER', false);
define('M3_INSTALL_PRE_FIXED_DB', true);
define('M3_INSTALL_DB_HOST',      '127.0.0.1');
define('M3_INSTALL_DB_NAME',      '${MYSQL_DATABASE}');
define('M3_INSTALL_DB_USER',      '${MYSQL_USER}');
define('M3_INSTALL_DB_PASSWORD',  '${MYSQL_PASSWORD}');
?>
_EOT_

exec "$@"
