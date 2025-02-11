#!/bin/bash

set -e -o pipefail

{
    {
        echo Compressing "${@:2}" to "$1" 
        zpaq a "$@" -m4 -s1 || echo "zpaq failed with error $?"
    } 2> >(
        tee -a zpaq.stderr.log \
        | awk '{print "\033[31m" strftime("%Y-%m-%d %H:%M:%S"), $0 "\033[0m"}' >&2
    )
} |& tee zpaq.last.log
