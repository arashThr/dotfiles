#!/bin/bash

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

# Install ZSH
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  # rm -rf $HOME/.oh-my-zsh/
  echo "oh-my-zsh already exists"
fi
sudo chsh -s /usr/bin/zsh nobody

# Config Git
curl -o ~/.git-prompt.sh https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

# Add new apps to ~/Documents/apps
local_bin="$HOME/Documents/apps"
mkdir -p $local_bin/bin
export PATH=$PATH:$local_bin/bin

# NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
omz reload
nvm install --lts

# JS/TS LSP
npm install -g typescript-language-server typescript
