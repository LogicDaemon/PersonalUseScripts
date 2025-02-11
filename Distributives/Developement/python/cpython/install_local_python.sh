#!/bin/bash
set -e
# shellcheck disable=SC2128
cd "$(dirname "$BASH_SOURCE")"
pyver="$(/usr/bin/python3 ./latest_python3.py check)"

sudo apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev
if [[ ! -f "Python-$pyver.extracted" || ! -d "Python-$pyver" ]]; then
    if [[ -f "Python-$pyver.tar.xz" ]]; then
        echo "Extracting existing Python-$pyver.tar.xz"
        xz -d < "Python-$pyver.tar.xz" | tar -xf -
    else
        echo Downloading https://www.python.org/ftp/python/$pyver/Python-$pyver.tar.xz and extracting...
        curl https://www.python.org/ftp/python/$pyver/Python-$pyver.tar.xz | tee "Python-$pyver.tar.xz.tmp" | xz -d | tar -xf -
        mv "Python-$pyver.tar.xz.tmp" "Python-$pyver.tar.xz"
    fi
    touch "Python-$pyver.extracted"
fi
pushd "Python-$pyver"
# https://stackoverflow.com/a/68247529/1421036
# For gcc
CFLAGS="-march=native -O3 -pipe" ./configure --prefix="$HOME/.local" --enable-optimizations --with-lto
# At this point you would traditional start building/compiling. However we want to further customise how the build will be with the extra options during profiling and during final release build.
# nano Makefile
# Search for "PGO_PROF_GEN_FLAG" (ctrl+w) And append after a space "-fprofile-update=prefer-atomic" without the quotes. It should look something like...
# PGO_PROF_GEN_FLAG=-fprofile-generate -fprofile-update=prefer-atomic
#     The next line underneath should say "PGO_PROF_USE_FLAG"; it affects the final release build/compile append "-fprofile-partial-training" after a space at the end without the quotes. It should look something like...
# PGO_PROF_USE_FLAG=-fprofile-use -fprofile-correction -fprofile-partial-training
# // added 2024-12-06: the above is still correct for Python-3.13.1, but the following is not.
#     Finally we extended the list of regression tests to run from the stock subset to the full set of tests. While still in "nano Makefile" search for "PROFILE_TASK= -m test --pgo" and replace it with:
# PROFILE_TASK=   -m test --pgo-extended
# // actual contents of Makefile for python 3.13.1 is:
# // # The task to run while instrumented when building the profile-opt target.
# // # To speed up profile generation, we don't run the full unit test suite
# // # by default. The default is "-m test --pgo". To run more tests, use
# // # PROFILE_TASK="-m test --pgo-extended"
# // PROFILE_TASK=	-m test --pgo --timeout=$(TESTTIMEOUT)
# // but when enabling pgo-extended, I get 
# // ./Modules/_blake2/impl/blake2s.c: In function ‘PyBlake2_blake2s’:
# // ./Modules/_blake2/blake2module.h:23:28: error: source locations for function ‘PyBlake2_blake2s’ have changed, the profile data may be out of date [-Werror=coverage-mismatch]
# //    23 | #define blake2s            PyBlake2_blake2s
# //       |                            ^~~~~~~~~~~~~~~~
# // ...
# // ./Modules/_blake2/impl/blake2b.c: In function ‘PyBlake2_blake2b_init_param’:
# // ./Modules/_blake2/blake2module.h:16:28: error: number of counters in profile data for function ‘PyBlake2_blake2b_init_param’ does not match its profile data (counter ‘arcs’, expected 3 and have 2) [-Werror=coverage-mismatch]
# //    16 | #define blake2b_init_param PyBlake2_blake2b_init_param
# //       |                            ^~~~~~~~~~~~~~~~~~~~~~~~~~~
# // so disabled for now --
# sed -i 's/^PGO_PROF_GEN_FLAG=-fprofile-generate$/PGO_PROF_GEN_FLAG=-fprofile-generate -fprofile-update=prefer-atomic/
#         s/^PGO_PROF_USE_FLAG=-fprofile-use -fprofile-correction$/PGO_PROF_USE_FLAG=-fprofile-use -fprofile-correction -fprofile-partial-training/
#         s/^PROFILE_TASK=\s*-m\s+test\s+--pgo.*$/PROFILE_TASK=	-m test --pgo-extended/
#         ' Makefile

time make "-j$(nproc)"
make install
popd

./zpaq-compress.sh prev-builds.zpaq "Python-$pyver"
rm -rf "Python-$pyver"
rm "Python-$pyver.extracted"
echo "Installed Python $pyver to $HOME/.local"
