#!/bin/sh
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

for rc_file in vimrc zshrc replyrc psqlrc emacs gitconfig gitignore_global; do
    link_file `pwd`/$rc_file $HOME/.$rc_file
done

# NVim configs
nvim_path=$HOME/.config/nvim
mkdir -p $nvim_path/lua/
link_file `pwd`/nvim/init.vim $nvim_path/init.vim
link_file `pwd`/nvim/plugins.lua $nvim_path/lua/plugins.lua

# Install my ZSH theme
theme_dir=$HOME/.oh-my-zsh/custom/themes
theme_file=$theme_dir/arash.zsh-theme

if [ -f $theme_dir ]; then
    echo '.oh-my-zsh directory does not exist. Skipping theme.'
else
    [[ -L $theme_file && -e $theme_file ]] || ln -s `pwd`/arash.zsh-theme $theme_file
fi

# Create config.d directory for SSH config files
ssh_dir=$HOME/.ssh
ssh_config=$ssh_dir/config

[ -d $ssh_dir/config.d ] || mkdir $ssh_dir/config.d
[ -L $ssh_config ] && rm $ssh_config
echo 'Linking ssh config file'
ln -s `pwd`/ssh-configs $ssh_config

