#!/bin/sh
set +x

target_dir="${1:-.}"
prospector -AX "$1" &
mypy "$target_dir" &
# not working with python > 3.9
# pytype -k "$target_dir" &
wait
