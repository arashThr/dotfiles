#!/bin/sh
set -eu

# Check zsh exists
if ! type zsh &> /dev/null; then
    echo 'ZSH command does not exits'
    exit 1
fi

for rc_file in vimrc zshrc replyrc psqlrc gitconfig; do
    file=$HOME/.$rc_file
    [[ -L $file ]] && rm $file
    echo "Linking $file to `pwd`/$rc_file"
    ln -s `pwd`/$rc_file $file
done

# Install my theme
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

