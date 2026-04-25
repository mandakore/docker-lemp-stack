COMPOSE_FILE	= srcs/docker-compose.yml

DATA_DIR		= /Users/atashiro/data

all: up

up:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) up -d

down:
	docker compose -f $(COMPOSE_FILE) down

build:
	@mkdir -p $(DATA_DIR)/mariadb
	@mkdir -p $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build --no-cache

re: down build up

clean:
	docker compose -f $(COMPOSE_FILE) down -v

fclean: clean
	docker system prune -af
	@rm -rf $(DATA_DIR)


.PHONY: all up down build re clean fclean
