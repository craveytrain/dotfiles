.PHONY: create pristine bash zsh

create:
	docker build -t prompt .

pristine:
	docker run -it ubuntu

bash: create
	docker run -it -v $(shell pwd):/root/.dotfiles prompt bash

zsh: create
	docker run -it -v $(shell pwd):/root/.dotfiles prompt zsh
