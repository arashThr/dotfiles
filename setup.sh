#!/bin/bash
# This script creates the RC files and sets up all the requirments for apps to
# start working properly

set -eu

# Check zsh exists
if ! type zsh &> /dev/null; then
    echo 'ZSH command does not exits'
    exit 1
fi

# RC files
link_file() {
    from=$1
    to=$2
    [[ -e $to ]] && rm $to
    echo "Linking $from to $to"
    ln -s $from $to
}

for rc_file in vimrc zshrc replyrc psqlrc emacs gitconfig gitignore_global tmux.conf ideavimrc; do
    link_file `pwd`/$rc_file $HOME/.$rc_file
done

# Install my ZSH theme
theme_dir=$HOME/.oh-my-zsh/custom/themes
theme_file=$theme_dir/arash.zsh-theme

if [ -f $theme_dir ]; then
    echo '.oh-my-zsh directory does not exist. Skipping theme.'
else
    [[ -L $theme_file && -e $theme_file ]] || ln -s `pwd`/arash.zsh-theme $theme_file
fi

# Neovim configs
nvim_path=$HOME/.config/nvim
[[ -d $nvim_path ]] || mkdir -p $nvim_path/lua/
link_file `pwd`/neovim/init.vim $nvim_path/init.vim
link_file `pwd`/neovim/plugins.lua $nvim_path/lua/plugins.lua

# Install plugins
git clone --depth 1 https://github.com/wbthomason/packer.nvim\
     ~/.local/share/nvim/site/pack/packer/start/packer.nvim
nvim -c 'PackerInstall' -c 'qa!'

# Install VIM plugins
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c 'PluginInstall' -c 'qa!'

# Create config.d directory for SSH config files
ssh_dir=$HOME/.ssh
ssh_config=$ssh_dir/config

[ -d $ssh_dir/config.d ] || mkdir $ssh_dir/config.d
[ -L $ssh_config ] && rm $ssh_config
echo 'Linking ssh config file'
ln -s `pwd`/ssh-configs $ssh_config

