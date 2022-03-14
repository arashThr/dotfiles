#!/bin/sh
set -eu

for rc_file in .vimrc .zshrc .replyrc .psqlrc; do
    file=$HOME/$rc_file
    if [ -f $file ]; then
        echo "$file already exists"
    else
        echo "Linking $file"
        ln -s `pwd`/$rc_file $file
    fi
done

