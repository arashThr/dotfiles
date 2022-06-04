#!/bin/bash
set -eu

# Install packages
sudo apt install -y build-essential autoconf automake pkg-config
# Editors
sudo apt install -y silversearcher-ag zsh emacs-nox tmux
# Man pages
sudo apt install -y man-db manpages-posix manpages-posix-dev

# Install ZSH
rm -rf $HOME/.oh-my-zsh/
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

sudo chsh -s /usr/bin/zsh nobody

# Config Git
curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Ctags
sudo snap install universal-ctags

# Install apps in ~/apps directory. This is included in .zshrc
local_bin="$HOME/apps"
mkdir -p $local_bin
export PATH=$PATH:$local_bin

# fzf
wget https://github.com/junegunn/fzf/releases/latest/download/fzf-0.30.0-linux_amd64.tar.gz -O ~/fzf.tar.gz
tar -xzf ~/fzf.tar.gz -C $local_bin
rm ~/fzf.tar.gz

# rg
wget https://github.com/BurntSushi/ripgrep/releases/download/12.1.1/ripgrep-12.1.1-x86_64-unknown-linux-musl.tar.gz -O ~/ripgrep.tar.gz
tar -xzf ~/ripgrep.tar.gz -C ~
cp ~/ripgrep-12.1.1-x86_64-unknown-linux-musl/rg $local_bin
rm -Rf ~/ripgrep*

# Github CLI
wget https://github.com/cli/cli/releases/latest/download/gh_2.10.1_linux_386.tar.gz -O ~/gh_1.tar.gz
tar -xzf ~/gh_1.tar.gz -C ~
cp ~/gh_1.10.3_linux_386/bin/gh $local_bin
rm -Rf ~/gh_1*

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
omz reload
nvm install --lts

# nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar -xzf nvim-linux64.tar.gz -C $local_bin
ln -s $local_bin/nvim-linux64/bin/nvim $local_bin

# CPAN modules
# cpanm -n Proc::InvokeEditor Reply::Plugin::Editor Perl::LanguageServer Term::ReadLine::Gnu
# cpanm --local-lib=~/perl5 local::lib && eval $(perl -I ~/perl5/lib/perl5/ -Mlocal::lib)

# DONE
# NOW YOU CAN RUN SETUP SCRIPT
