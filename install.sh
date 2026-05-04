#!/bin/bash

set -e

REPO="sky43535/skyfile"

OS="$(uname -s)"

echo "Installing skyfile..."

if [ "$OS" = "Darwin" ]; then
    URL="https://github.com/$REPO/releases/latest/download/skyfile"
elif [ "$OS" = "Linux" ]; then
    URL="https://github.com/$REPO/releases/latest/download/skyfile"
else
    echo "Unsupported OS: $OS"
    exit 1
fi

curl -L "$URL" -o skyfile
chmod +x skyfile
sudo mv skyfile /usr/local/bin/skyfile

echo "Installed skyfile successfully!"
skyfile --help