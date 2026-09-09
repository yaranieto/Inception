#!/bin/bash
# ************************************************************************** #
#                                                                            #
#                                                        :::      ::::::::   #
#   entrypoint.sh                                      :+:      :+:    :+:   #
#                                                    +:+ +:+         +:+     #
#   By: ynieto-s <ynieto-s@student.42.fr>          +#+  +:+       +#+        #
#                                                +#+#+#+#+#+   +#+           #
#   Created: 2026/08/15 16:32:00 by ynieto-s          #+#    #+#             #
#   Updated: 2026/09/06 19:30:00 by ynieto-s         ###   ########.fr       #
#                                                                            #
# ************************************************************************** #

set -e

DB_ROOT_PASSWORD=$(tr -d '\r\n' < /run/secrets/db_root_password)
DB_PASSWORD=$(tr -d '\r\n' < /run/secrets/db_password)
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"

sql_escape() {
    printf '%s' "$1" | sed "s/'/''/g"
}

DB_ROOT_PASSWORD_SQL=$(sql_escape "${DB_ROOT_PASSWORD}")
DB_PASSWORD_SQL=$(sql_escape "${DB_PASSWORD}")

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

# Marker alone is not enough: a partial wipe (e.g. `rm -rf datadir/*`) can leave
# .inception_initialized while deleting the mysql system tables.
needs_init=0
if [ ! -f /var/lib/mysql/.inception_initialized ]; then
    needs_init=1
elif [ ! -d /var/lib/mysql/mysql ]; then
    echo "Incomplete MariaDB datadir detected; re-initializing..."
    needs_init=1
fi

if [ "${needs_init}" -eq 1 ]; then
    echo "Initializing MariaDB data directory..."
    # Remove everything including hidden marker/files.
    find /var/lib/mysql -mindepth 1 -delete
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --skip-test-db

    mysqld --user=mysql --datadir=/var/lib/mysql --bootstrap <<EOF
FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD_SQL}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD_SQL}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    touch /var/lib/mysql/.inception_initialized
    chown mysql:mysql /var/lib/mysql/.inception_initialized
    echo "MariaDB initialization complete."
fi

exec "$@"
