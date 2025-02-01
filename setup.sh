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

for rc_file in vimrc zshrc psqlrc gitconfig gitignore_global tmux.conf localrc_sample; do
    read -p "Replace $rc_file? " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        continue
    fi
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
mkdir -p $nvim_path/lua/user/
link_file `pwd`/neovim/user/task.lua $nvim_path/lua/user/task.lua

# LSP Config
if [ ! -d ~/.local/share/nvim/site/pack/packer ]; then
  git clone https://github.com/neovim/nvim-lspconfig ~/.config/nvim/pack/nvim/start/nvim-lspconfig
  # Install plugins
  echo "Installing Packer"
  git clone --depth 1 https://github.com/wbthomason/packer.nvim\
     ~/.local/share/nvim/site/pack/packer/start/packer.nvim
fi
nvim -c 'PackerInstall' -c 'qa!'


# Install VIM plugins
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
  echo "Installing Vundle for VIM"
  git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim -c 'PluginInstall' -c 'qa!'

# Create config.d directory for SSH config files
ssh_dir=$HOME/.ssh
ssh_config=$ssh_dir/config

[ -d $ssh_dir/config.d ] || mkdir $ssh_dir/config.d
[ -L $ssh_config ] && echo "Removing $ssh_config" && rm $ssh_config
echo "Linking ssh config file at $ssh_config"
ln -s `pwd`/ssh-config $ssh_config

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
nvm install --lts

# JS/TS LSP
npm install -g typescript-language-server typescript yarn

