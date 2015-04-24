FROM ubuntu
MAINTAINER Mike Cravey <techie@craveytrain.com>

# Fake SSH so user and host show up in prompt
ENV SSH_CONNECTION=1

# Install ZSH
RUN apt-get install -y zsh

# Create mount point for host directory
VOLUME /root/.dotfiles

# Copy files over so you can run bootstrap but will be overwritten
COPY . /root/.dotfiles/
RUN /root/.dotfiles/bootstrap
