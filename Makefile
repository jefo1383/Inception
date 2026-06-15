.PHONY: all down clean fclean re status logs

all:
	mkdir -p /home/jfoeller/data/mariadb
	mkdir -p /home/jfoeller/data/wordpress
	cd srcs && docker compose up -d --build

down:
	cd srcs && docker compose down

clean:
	cd srcs && docker compose down --rmi all

fclean: clean
	sudo rm -rf /home/jfoeller/data/mariadb
	sudo rm -rf /home/jfoeller/data/wordpress

re: fclean all

status:
	docker compose -f srcs/docker-compose.yml ps

logs:
	docker compose -f srcs/docker-compose.yml logs