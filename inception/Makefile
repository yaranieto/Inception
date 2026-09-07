# ************************************************************************** #
#                                                                            #
#                                                        :::      ::::::::   #
#   Makefile                                             :+:      :+:    :+:   #
#                                                    +:+ +:+         +:+     #
#   By: ynieto-s <ynieto-s@student.42.fr>            +#+  +:+       +#+      #
#                                                +#+#+#+#+#+   +#+           #
#   Created: 2026/08/15 16:32:00 by ynieto-s           #+#    #+#             #
#   Updated: 2026/09/06 19:40:00 by ynieto-s           ###   ########.fr      #
#                                                                            #
# ************************************************************************** #

NAME		= inception

# Always bind volumes under the current user's home (evaluation VM login).
DATA_DIR	= $(HOME)/data
export DATA_PATH := $(DATA_DIR)

COMPOSE		= docker compose -f srcs/docker-compose.yml

all: setup build up

setup:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up -d

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down --rmi local --volumes --remove-orphans

fclean: clean
	@sudo rm -rf $(DATA_DIR)/mariadb/* $(DATA_DIR)/wordpress/*

re: fclean all

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all setup build up down clean fclean re logs ps
