#!/usr/bin/env sh

set -x -e

rm hello.bin hello.sym obj/bootstrap.o obj/init.o || true

i686-elf-as -o obj/hello.o hello.s
i686-elf-gcc -T linker.ld -o hello.bin -ffreestanding -O2 -nostdlib -lgcc -m32 obj/*.o

$(pwd)/dbg/generate-sym.sh hello.bin

