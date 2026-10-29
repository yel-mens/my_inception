LOGIN = yel-mens

COMPOSE = docker compose --env-file srcs/.env -f srcs/docker-compose.yml

all: up

dirs:
	@mkdir -p /home/$(LOGIN)/data/mariadb
	@mkdir -p /home/$(LOGIN)/data/wordpress

up: dirs
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v --remove-orphans

fclean: clean
	@docker system prune -af

install:
	@sudo apt upgrade
	@sudo apt install docker.io
	@sudo usermod -aG docker $(USER)
	@newgrp docker

re: fclean all

db-shell:
	$(COMPOSE) exec mariadb sh -c 'exec mariadb --protocol=TCP -h 127.0.0.1 -u "$$DB_USER" -p "$$DB_NAME"'

.PHONY:
	all up down clean fclean re dirs db-shell
