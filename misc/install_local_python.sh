#!/bin/bash
set -e

pyver=3.10.2

sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
curl https://www.python.org/ftp/python/$pyver/Python-$pyver.tar.xz | xz -d | tar -xf -
cd Python-$pyver
./configure --prefix="$HOME/.local" --enable-optimizations
make -j$(nproc)
make install
