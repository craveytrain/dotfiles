# What it is?!
This is my own personal dotfile repo. There are many others like it but this one is mine. If you're interested, feel free to fork, poach, whatever.

## Prompt

The user and host is gone for a local prompt. I work on a mac or ubuntu primarily, both of which promote heavy use of `sudo`. As such showing the user on my local system is unnecessary. I know what user I am logged in as, I know what system I am on.

However, if I am SSH'd in somewhere, I want to know who I am as and what host I am on. So, if I am ssh'd somewhere, I show the user and hostname, otherwise just start off in the directory.

## Shell

I've gone full zsh. Bash utils are not even included any more.

# Install
1. Clone the repo (be sure to grab submodules)

```sh
git clone --recursive git@github.com:craveytrain/dotfiles.git
```
2. Get inside the repo

```sh
cd dotfiles
```

3. Run the Rakefile

```sh
rake install
```

4. Change shell to zsh

```sh
# check to see if zsh is installed
which zsh

# if not, install it (sudo apt-get install zsh, sudo brew install zsh, etc)

# change shell
chsh -s $(which zsh)
```

# Credits
Thanks to [mschout](https://github.com/mschout) for all the help, especially on the bash stuff.

Thanks to [holman](https://github.com/holman) for the Rakefile and inspiration for things such as the topical organization and prompt.

# TODO
- Linux dir colors (dircolors?)
- Ease installation (shell script to fetch, install homebrew and formulas & other dependencies cross platform?)