# ************************************************************************** #
#                                                                            #
#                                                        :::      ::::::::   #
#   Dockerfile                                           :+:      :+:    :+:   #
#                                                    +:+ +:+         +:+     #
#   By: ynieto-s <ynieto-s@student.42.fr>            +#+  +:+       +#+        #
#                                                +#+#+#+#+#+   +#+           #
#   Created: 2026/08/15 16:32:00 by ynieto-s           #+#    #+#             #
#   Updated: 2026/08/15 16:38:00 by ynieto-s           ###   ########.fr       #
#                                                                            #
# ************************************************************************** #

FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    gettext-base \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl /var/run/nginx

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh \
    && rm -f /etc/nginx/conf.d/default.conf

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
