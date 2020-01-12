#!/bin/sh
DOTFILES=(.bash_profile .bashrc .zprofile .zshrc .tmux.conf .vimrc .vim .ideavimrc .gprompt .config/peco/config.json)

for file in ${DOTFILES[@]}
do
    if [ ! -L $HOME/$file ]; then
        ln -fnsv $HOME/dotfiles/$file $HOME/$file
    fi
done
