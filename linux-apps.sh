#!/bin/bash
set -eu

# Install packages
sudo apt install -y build-essential autoconf automake pkg-config git
# Editors
sudo apt install -y silversearcher-ag zsh emacs-nox tmux
# Man pages
sudo apt install -y man-db manpages-posix manpages-posix-dev
# Programs
sudo apt install -y jq ripgrep fzf vim neovim

# Ctags
# sudo snap install universal-ctags

# DONE
# NOW YOU CAN RUN SETUP SCRIPT
