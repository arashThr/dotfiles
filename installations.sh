#!/bin/bash

# Install packages
sudo apt-get -y install silversearcher-ag zsh exuberant-ctags man-db emacs-nox manpages-posix manpages-posix-dev tmux cpanminus
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

sudo chsh -s /usr/bin/zsh nobody

# Setup configs
workspace_path=$HOME/Documents/workspace
mkdir -p $workspace_path/github
git clone git@github.com:arashThr/dotfiles.git $workspace_path/github/dotfiles
setup_configs=$workspace_path/github/dotfiles/setup.sh
chmod +x $setup_configs
./$setup_configs

# Config Git
curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Install Vim plugins
vim -c 'PluginInstall' -c 'qa!'
nvim -c 'PackerInstall' -c 'qa!'

# Ctags
# sudo apt-get -y install exuberant-ctags
# sudo snap install universal-ctags
git clone https://github.com/universal-ctags/ctags.git
cd ctags
./autogen.sh
./configure # defaults to /usr/local
make
make install # may require extra privileges depending on where to install
rm -rf ctags

# CPAN modules
cpanm -n Proc::InvokeEditor Reply::Plugin::Editor Perl::LanguageServer Term::ReadLine::Gnu

# Add new apps to ~/apps
local_bin="$HOME/apps"
mkdir $local_bin
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

# nvim
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz
tar -xzf nvim-linux64.tar.gz -C $local_bin
ln -s $local_bin/nvim-linux64/bin/nvim $local_bin

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
nvm install --lts

alias fixssh='eval $(tmux showenv -s SSH_AUTH_SOCK)'

