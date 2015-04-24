.PHONY: create bash zsh

create:
	docker build -t prompt .

bash:
	docker run -it -v $(shell pwd):/root/.dotfiles prompt /bin/bash

zsh:
	docker run -it -v $(shell pwd):/root/.dotfiles prompt /bin/zsh
