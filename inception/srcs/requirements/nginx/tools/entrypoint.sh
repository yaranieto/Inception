#!/bin/bash
# ************************************************************************** #
#                                                                            #
#                                                        :::      ::::::::   #
#   entrypoint.sh                                      :+:      :+:    :+:   #
#                                                    +:+ +:+         +:+     #
#   By: ynieto-s <ynieto-s@student.42.fr>          +#+  +:+       +#+        #
#                                                +#+#+#+#+#+   +#+           #
#   Created: 2026/08/15 16:32:00 by ynieto-s          #+#    #+#             #
#   Updated: 2026/08/15 16:38:00 by ynieto-s         ###   ########.fr       #
#                                                                            #
# ************************************************************************** #

set -e

if [ ! -f /etc/nginx/ssl/server.crt ]; then
    echo "Generating self-signed TLS certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/server.key \
        -out /etc/nginx/ssl/server.crt \
        -subj "/CN=${DOMAIN_NAME}"
fi

envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf.template \
    > /etc/nginx/conf.d/default.conf

exec "$@"
