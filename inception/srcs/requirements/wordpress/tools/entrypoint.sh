#!/bin/bash
# ************************************************************************** #
#                                                                            #
#                                                        :::      ::::::::   #
#   entrypoint.sh                                        :+:      :+:    :+:   #
#                                                    +:+ +:+         +:+     #
#   By: ynieto-s <ynieto-s@student.42.fr>            +#+  +:+       +#+        #
#                                                +#+#+#+#+#+   +#+           #
#   Created: 2026/08/15 16:32:00 by ynieto-s           #+#    #+#             #
#   Updated: 2026/09/06 13:08:00 by ynieto-s           ###   ########.fr       #
#                                                                            #
# ************************************************************************** #

set -e

DB_PASSWORD=$(tr -d '\r\n' < /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(tr -d '\r\n' < /run/secrets/credentials)

DB_HOST="mariadb"
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
MY_CNF="/tmp/.my.cnf"

write_db_defaults() {
    cat > "${MY_CNF}" <<EOF
[client]
host=${DB_HOST}
user=${DB_USER}
password=${DB_PASSWORD}
EOF
    chmod 600 "${MY_CNF}"
}

wait_for_db() {
    echo "Waiting for MariaDB..."
    write_db_defaults
    until mariadb --defaults-extra-file="${MY_CNF}" -e "SELECT 1" &>/dev/null; do
        sleep 2
    done
    echo "MariaDB is ready."
}

seed_wordpress_files() {
    if [ ! -f /var/www/html/index.php ]; then
        echo "Seeding WordPress files into persistent volume..."
        cp -a /var/www/wordpress-staging/. /var/www/html/
        chown -R www-data:www-data /var/www/html
    fi
}

configure_wordpress() {
    seed_wordpress_files
    cd /var/www/html

    if [ ! -f wp-config.php ]; then
        wp config create \
            --dbname="${DB_NAME}" \
            --dbuser="${DB_USER}" \
            --dbpass="${DB_PASSWORD}" \
            --dbhost="${DB_HOST}" \
            --skip-check \
            --allow-root
        wp config set DB_PASSWORD "${DB_PASSWORD}" --type=constant --allow-root
    fi

    if ! wp core is-installed --allow-root 2>/dev/null; then
        echo "Installing WordPress..."
        wp core install \
            --url="https://${DOMAIN_NAME}" \
            --title="${WP_TITLE}" \
            --admin_user="${WP_ADMIN_USER}" \
            --admin_password="${WP_ADMIN_PASSWORD}" \
            --admin_email="${WP_ADMIN_EMAIL}" \
            --skip-email \
            --allow-root

        wp user create "${WP_USER2}" "${WP_USER2_EMAIL}" \
            --role=editor \
            --user_pass="${WP_ADMIN_PASSWORD}" \
            --allow-root
    fi
}

wait_for_db
configure_wordpress
rm -f "${MY_CNF}"

exec "$@"
