[org 0x7E00]

; Change background color to blue to prove the kernel is running!
mov ax, 0xB800
mov es, ax
mov di, 0

mov ah, 0x1F ; Blue background, White text
mov al, 'K'
stosw        ; Write 'K' to top-left corner

hang:
    hlt
    jmp hang