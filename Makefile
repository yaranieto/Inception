# ************************************************************************** #
#                                                                            #
#                                                        :::      ::::::::   #
#   Makefile                                             :+:      :+:    :+:   #
#                                                    +:+ +:+         +:+     #
#   By: ynieto-s <ynieto-s@student.42.fr>            +#+  +:+       +#+      #
#                                                +#+#+#+#+#+   +#+           #
#   Created: 2026/08/15 16:32:00 by ynieto-s           #+#    #+#             #
#   Updated: 2026/09/19 18:20:00 by ynieto-s           ###   ########.fr      #
#                                                                            #
# ************************************************************************** #

NAME		= inception

LOGIN		:= $(shell id -un)
DATA_DIR	:= $(if $(wildcard /home/$(LOGIN)),/home/$(LOGIN)/data,$(HOME)/data)
export DATA_PATH := $(DATA_DIR)

COMPOSE		= docker-compose -f srcs/docker-compose.yml

all: setup build up

setup:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@chmod 755 $(DATA_DIR) $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@test -d $(DATA_DIR)/mariadb || (echo "Error: cannot create $(DATA_DIR)/mariadb" && exit 1)
	@test -d $(DATA_DIR)/wordpress || (echo "Error: cannot create $(DATA_DIR)/wordpress" && exit 1)

build: setup
	$(COMPOSE) build

up: setup
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --rmi local --volumes --remove-orphans

fclean: clean
	@sudo rm -rf $(DATA_DIR)
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

re: fclean all

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all setup build up down clean fclean re logs ps
