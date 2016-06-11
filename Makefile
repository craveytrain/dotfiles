.PHONY: create bash zsh

create:
	docker build -t prompt .

bash: create
	docker run -it -v $(shell pwd):/root/.dotfiles prompt /bin/bash

zsh: create
	docker run -it -v $(shell pwd):/root/.dotfiles prompt /bin/zsh
