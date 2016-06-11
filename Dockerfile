FROM ubuntu
MAINTAINER Mike Cravey <techie@craveytrain.com>

# Fake SSH so user and host show up in prompt
ENV SSH_CONNECTION=1

# Create mount point for host directory
VOLUME /root/.dotfiles
# Copy files over so you can run bootstrap but will be overwritten
COPY . /root/.dotfiles/

# Install ZSH
RUN apt-get update
RUN apt-get install -y zsh git

RUN /root/.dotfiles/bootstrap
