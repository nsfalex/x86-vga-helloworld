#!/usr/bin/env sh

[ -z "$1" ] && \
    echo "Need a filename to create from objects." && \
    exit 1

i686-elf-gcc -T linker.ld -o "$1" -ffreestanding -O2 -nostdlib -lgcc obj/*.o
