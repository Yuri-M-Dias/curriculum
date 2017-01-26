#!/bin/sh

set -e

echo "Copying fonts to the global font cache"
sudo cp fonts/fontin /usr/share/fonts -R

echo "Updating local font cache"
sudo fc-cache -fv
