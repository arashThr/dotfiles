#!/bin/sh
set -eu

ssh_dir=$HOME/.ssh
ssh_config=$ssh_dir/config
theme_dir=$HOME/.oh-my-zsh/custom/themes
theme_file=$theme_dir/arash.zsh-theme

if ! type zsh &> /dev/null; then
    # TODO: Install zsh
    echo 'ZSH command does not exits'
    exit 1
fi

for rc_file in .vimrc .zshrc .replyrc .psqlrc; do
    file=$HOME/$rc_file
    if [ -f $file ]; then
        echo "$file already exists"
    else
        echo "Linking $file"
        ln -s `pwd`/$rc_file $file
    fi
done

# Install my theme
if [ -f $theme_dir ]; then
    echo '.oh-my-zsh directory does not exist. Skipping theme.'
else
    [[ -L $theme_file && -e $theme_file ]] || ln -s `pwd`/arash.zsh-theme $theme_file
fi

# Create config.d directory for SSH config files
[ -d $ssh_dir/config.d ] || mkdir $ssh_dir/config.d

if [ -f $ssh_config ]; then
    echo "$ssh_config file already exists"
else
    echo 'Linking ssh config file'
    ln -s `pwd`/ssh-configs $ssh_config
fi

