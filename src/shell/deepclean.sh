#!/usr/bin/env sh

set -e

if [ -z "$1" ]; then
    echo "Refusing to deepclean without directory specified."
    echo "THIS SCRIPT SHOULD ONLY BE CALLED FROM THE BUILD ENV"
    echo "Usage: deepclean.sh <directory_path>"
    exit 1
fi

keep="src grub CMakeLists.txt linker.ld .git .gitignore LICENSE README.md"

check_file() {
    for keepfile in $keep; do
        [ "$1" = "$keepfile" ] && return 1
    done
    return 0
}

for file in `ls -a $1`; do
    [ $file = "." ] || [ $file = ".." ] && continue
    check_file $file && rm -rvf $file
done
