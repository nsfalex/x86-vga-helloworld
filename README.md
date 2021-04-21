# kernel-assembly

x86 VGA text mode hello world, implemented entirely in assembly.  
Entry code and linker script originally from the [OSDev.org wiki](https://wiki.osdev.org/Bare_Bones).

### Build

```bash
i686-elf-as -o hello.o hello.s
i686-elf-gcc -T linker.ld -ffreestanding -O2 -nostdlib -lgcc -m32 -o hello.bin hello.o 
```

### Run
```bash
qemu-system-x86_64 -kernel hello.bin

or

qemu-system-i386 -kernel hello.bin
```

![QEMU VGA display](http://10.10.10.1:3000/alex/kernel-assembly/raw/branch/master/img/qemu-system.png)
