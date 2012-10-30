#!/bin/bash
DOTFILES_DIR=".dotfiles"
DOTFILES="$HOME/$DOTFILES_DIR"
GIT_REPO="craveytrain/dotfiles"

## Grab dotfiles
if [ ! -d "$DOTFILES" ]; then
	## Prefer git clone
	if [ -x "$(which git)" ]; then
		## CLone git repo if not already there
		git clone --recursive "git://github.com/$GIT_REPO.git" "$DOTFILES"
	else
		if [ ! -x $(which curl) ]; then echo "Curl not found, giving up."; exit 1; fi

		echo "Git not found. Copying instead."
		mkdir "$DOTFILES_DIR";
		curl -L "https://github.com/$GIT_REPO/tarball/master" | tar zx -C "$DOTFILES_DIR" --strip-components 1
	fi
fi


## Create placeholder directories if not already there
for DIR in $(find $DOTFILES -name "*.copy"); do
	DIR_NAME="$(basename ${DIR%.copy})"
	NEW_DIR="$HOME/.$DIR_NAME"
	if [ ! -d "$NEW_DIR" ]; then
		mkdir "$NEW_DIR"
	fi

	## Symlink contents of placeholder directories (if they are directories)
	if [ -d "$DIR" ]; then
		for FILE in $(ls $DIR); do
			NEW_FILE="$NEW_DIR/$FILE"
			## If not a symlink already
			if [ ! -L "$NEW_FILE" ]; then

				## If the file exists (just not a symlink), back it up
				if [ -e "$NEW_FILE" ]; then
					echo "Backup: ${NEW_FILE/$HOME/~} -> ${NEW_FILE/$HOME/~}.backup"
					mv "$NEW_FILE" "$NEW_FILE.backup"
				fi

				## Create the symlink
				ln -s "$DIR/$FILE" "$NEW_FILE"
			fi
		done
	fi
done

## Symlink all the things!
for SYMLINK in $(find $DOTFILES -name "*.symlink"); do
	BASE_NAME="$(basename ${SYMLINK%.symlink})"
	NEW_FILE="$HOME/.$BASE_NAME"

	## If the new file isn't a symlink
	if [ ! -L "$NEW_FILE" ]; then

		## If the file already exists (just not a symlink), back it up
		if [ -e "$NEW_FILE" ]; then
			echo "Backup: $(basename $NEW_FILE) -> $(basename $NEW_FILE).backup"
			mv "$NEW_FILE" "$NEW_FILE.backup"
		fi

		## Create the symlink
		ln -s "$SYMLINK" "$NEW_FILE"

	fi
done

## Fix origin to use SSH variant (TODO: need to check if able to commit)
# if [ -x "$(which git)" ]; then
#	cd "$DOTFILES";
#	git remote set-url origin "git@github.com:$GIT_REPO.git"
# fi

echo "Please restart your shell"

exit 0;
