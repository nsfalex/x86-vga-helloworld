#!/usr/bin/env sh

set -x -e

rm hello.bin hello.sym obj/bootstrap.o obj/init.o || true

i686-elf-as -o obj/bootstrap.o bootstrap.s && i686-elf-as -o obj/init.o init.s
i686-elf-gcc -T linker.ld -o hello.bin -ffreestanding -O2 -nostdlib -lgcc -m32 obj/bootstrap.o obj/init.o

$(pwd)/dbg/generate-sym.sh hello.bin

