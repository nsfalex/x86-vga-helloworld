# x86-vga-helloworld

x86 VGA text mode hello world, implemented entirely in assembly.
Bootstrap code and linker script originally from the [OSDev.org wiki](https://wiki.osdev.org/Bare_Bones).

### Build

```shell
i686-elf-as -o hello.o hello.s
i686-elf-gcc -T linker.ld -ffreestanding -O2 -nostdlib -lgcc -m32 -o hello.bin hello.o 
```

### Run
```shell
qemu-system-x86_64 -kernel hello.bin

or

qemu-system-i386 -kernel hello.bin
```

![QEMU VGA display](https://github.com/nsfalex/x86-vga-helloworld/raw/main/img/qemu-system.png)
