FROM ubuntu
MAINTAINER Mike Cravey <techie@craveytrain.com>

# Fake SSH so user and host show up in prompt
ENV SSH_CONNECTION=1

# Create mount point for host directory
VOLUME /root/.dotfiles

# Install ZSH
RUN apt-get update && apt-get install -y zsh git python dnsutils

# Copy files over so you can run `install` but will be overwritten
COPY . /root/.dotfiles/

RUN /root/.dotfiles/bootstrap
