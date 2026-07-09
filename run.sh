nasm -f bin src/boot.asm -o out/boot.bin
qemu-system-x86_64 -drive format=raw,file=out/boot.bin
