# What it is?!

This is my own personal dotfile repo. There are many others like it but this one is mine. If you're interested, feel free to fork, poach, whatever.

## Prompt

The user and host is gone for a local prompt. I work on a mac primarily, which promotes heavy use of `sudo`. As such showing the user on my local system is unnecessary. I know what user I am logged in as, I know what system I am on.

However, if I am SSH'd in somewhere, I want to know who I am as and what host I am on. So, if I am ssh'd somewhere, I show the user and hostname, otherwise just start off in the directory.

## Shell

While I've gone full zsh on systems I have full control over, occasionally I have to use bash, so I've tried to cobble some basic support for it.

# Install

```bash
# Boot the straps!
curl -Lks https://raw.githubusercontent.com/craveytrain/dotfiles/main/.bin/install.sh | /bin/bash

# Change shell to zsh (optional)
chsh -s $(which zsh)

# Restart your shell
```

# Credits

Thanks to [mschout](https://github.com/mschout) for all the help, especially on the bash stuff.

Thanks to [holman](https://github.com/holman) for the inspiration for things such as the topical organization and prompt.

And many others for your inspirations and perspirations.
