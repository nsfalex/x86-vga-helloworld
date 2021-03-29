#!/usr/bin/env sh

isodir="iso"

[ -z "$2" ] && exit 1

bname=`basename $1`
isodir="${1}/${isodir}"

mkdir -p "$2/${isodir}/boot/grub"

cp ${bname}.bin        "${isodir}/boot/${bname}.bin"
cp ${2}/grub/grub.cfg  "${isodir}/boot/grub/grub.cfg"

grub-mkrescue -o ${bname}.iso ${isodir}
