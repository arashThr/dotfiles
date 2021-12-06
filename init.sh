#!/bin/bash

sudo apt -y install zsh git curl silversearcher-ag exuberant-ctags man-db vim tmux

# dotfiles
wget -O ~/.vimrc https://raw.githubusercontent.com/arashthr/dotfiles/master/.vimrc
wget -O ~/.tmux.conf https://raw.githubusercontent.com/arashthr/dotfiles/master/.tmux.conf
wget -O ~/.psqlrc https://raw.githubusercontent.com/arashthr/dotfiles/master/.psqlrc
wget -O ~/.replyrc https://raw.githubusercontent.com/arashthr/dotfiles/master/.replyrc
wget -O ~/.zshrc https://raw.githubusercontent.com/arashthr/dotfiles/master/.zshrc

# Vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim -c 'PluginInstall' -c 'qa!'

# oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Git
git config --global user.name "Arash Taher"
git config --global user.email "arashthr@outlook.com"
git config --global color.ui true
git config --global color.status true
git config --global color.diff true
git config --global core.pager "less -r"
git config --global core.editor "vim"
git config --global core.excludesfile "$HOME/.gitignore"

curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh
cat > $HOME/.gitignore << 'GIT'
vscode
vstags
*.swp
.build/
GIT

# Add new apps to ~/apps
local_bin="$HOME/Documents/apps"
mkdir -p $local_bin
export PATH=$PATH:/home/git/regentmarkets/environment-manifests-qa/bin:$local_bin

# fzf
wget https://github.com/junegunn/fzf/releases/download/0.24.3/fzf-0.24.3-linux_amd64.tar.gz -O ~/fzf.tar.gz
tar -xzf ~/fzf.tar.gz -C $local_bin
rm ~/fzf.tar.gz

# rg
wget https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep-12.1.1-x86_64-unknown-linux-musl.tar.gz -O ~/ripgrep.tar.gz
tar -xzf ~/ripgrep.tar.gz -C ~
cp ~/ripgrep-12.1.1-x86_64-unknown-linux-musl/rg $local_bin
rm -Rf ~/ripgrep*

# Github CLI
wget https://github.com/cli/cli/releases/download/v1.10.3/gh_1.10.3_linux_386.tar.gz -O ~/gh_1.tar.gz
tar -xzf ~/gh_1.tar.gz -C ~
cp ~/gh_1.10.3_linux_386/bin/gh $local_bin
rm -Rf ~/gh_1*

