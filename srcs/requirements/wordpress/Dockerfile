# ************************************************************************** #
#                                                                            #
#                                                        :::      ::::::::   #
#   Dockerfile                                           :+:      :+:    :+:   #
#                                                    +:+ +:+         +:+     #
#   By: ynieto-s <ynieto-s@student.42.fr>            +#+  +:+       +#+        #
#                                                +#+#+#+#+#+   +#+           #
#   Created: 2026/08/15 16:32:00 by ynieto-s           #+#    #+#             #
#   Updated: 2026/09/06 13:08:00 by ynieto-s           ###   ########.fr       #
#                                                                            #
# ************************************************************************** #

FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    mariadb-client \
    php-fpm \
    php-mysql \
    php-curl \
    php-gd \
    php-intl \
    php-mbstring \
    php-xml \
    php-zip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www \
    && curl -fsSL https://wordpress.org/latest.tar.gz \
    | tar -xz -C /var/www \
    && mv /var/www/wordpress /var/www/wordpress-staging \
    && chown -R www-data:www-data /var/www/wordpress-staging

RUN curl -fsSL https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    -o /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /tmp/www.conf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN PHP_VER=$(php -r 'echo PHP_MAJOR_VERSION.".".PHP_MINOR_VERSION;') \
    && cp /tmp/www.conf /etc/php/${PHP_VER}/fpm/pool.d/www.conf \
    && rm /tmp/www.conf \
    && ln -sf /usr/sbin/php-fpm${PHP_VER} /usr/local/bin/php-fpm \
    && chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/local/bin/php-fpm", "-F"]
