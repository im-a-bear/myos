#!/bin/bash
mkdir -p out

# Compile bootloader (Sector 1)
nasm -f bin src/boot.asm -o out/boot.bin

# Compile dummy kernel (Sector 2+)
nasm -f bin src/mode_change.asm -o out/kernel.bin

# Stitch them together into a single OS disk image
cat out/boot.bin out/kernel.bin > out/os_image.bin

# Run the final disk image in QEMU
qemu-system-x86_64 -drive format=raw,file=out/os_image.bin