#!/bin/bash
TARGET=("tmux" "zplug" "peco" "tig")

for pkg in "${TARGET[@]}"; do
    if brew list -1 | grep -q "^$pkg\$"; then
        echo "$pkg is already installed. Skipping..."
    else
        echo "Installing $pkg..."
        brew install "$pkg"
        if [ $? -eq 0 ]; then
            echo "$pkg installed successfully."
        else
            echo "Failed to install $pkg."
        fi
    fi
done
