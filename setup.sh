#!/bin/sh
set -eu

for rc_file in .vimrc .zshrc .replyrc; do
    if [ -f $rc_file ]; then
        echo "$rc_file already exists"
    else
        ln -s `pwd`/$rc_file ~/$rc_file
    fi
done

