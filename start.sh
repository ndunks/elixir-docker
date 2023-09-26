#!/bin/bash

git config --global --add safe.directory $LXR_REPO_DIR
if [ ! -d $LXR_DATA_DIR ]; then
    echo "Building for $PROJECT"
    mkdir -p $LXR_DATA_DIR
    
    cd /usr/local/elixir/
    ./script.sh list-tags
    python3 -u ./update.py
fi

exec /usr/sbin/apache2ctl -D FOREGROUND
