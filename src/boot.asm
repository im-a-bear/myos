; --- CONSTANTS ---

; magic constants
%define START_AT 0x7C00
%define PADDING 512
%define MAGIC_NUMBER 0xAA55

; string constants
%define CARRIAGE_RETURN 0x0D
%define LINE_FEED 0x0A

; bios interrupts
%define BIOS_INTERRUPT 0x10
%define BIOS_WRITE 0x13
%define VIDEO_FUNC 0x0E
%define SECTOR_READ 0x02
%define CURSOR_TYPE_FUNC 0x01

; bios info
%define INVISIBLE_CURSOR 0x3F

; colors
%define BASE_TEXT_COLOR 0x6D
%define BACKGROUND_COLOR 0x6F
%define ERROR_TEXT 0x64

; VGA
%define VGA_MEMORY 0xB800
%define SCREEN_SIZE 2000
%define SCREEN_X 80
%define SCREEN_Y 25

; math
%define MATH_XOR_ROUND 0xFFFE

; --- DISK SETTINGS --- (really, really important!)
%define HEAD 0
%define CYLINDER 0
%define KERNEL_ADDR 0x7E00

; --- TEXT ---
[org START_AT] ; start at 7c00

; make call stack available

; disable interrupts
cli

; dense the registers
xor ax, ax
mov ss, ax

; make the stack available
mov sp, START_AT

; re enable inputs
sti

; push dl we need this later
push dx

; configure lodsb
mov ds, ax ; ax is alredy 0
cld

; configure VGA
mov ax, VGA_MEMORY
mov es, ax
mov di, 0

main:
    ; handle newlines first
    xor bl, bl

    ; clear screen first and hide the cursor
    call cursor_hide
    call clear_screen
    
    ; print before hanging

    ; set the string first
    mov si, hello

    ; do the math along with chaining the string length
    call get_string_length
    call math_center

    ; set color last
    mov ah, BASE_TEXT_COLOR

    call print_string

    jmp load_kernel ; jump to hang

print_string:
    ; a full fledged printing function that uses print
    ; check for new lines
    ; dont overide values
    push ax
    mov al, (SCREEN_X * 2)

    ; multiply and append
    mul bl
    add di, ax

    ; pop
    pop ax

.loop:
    ; check for null an exit
    lodsb
    cmp al, 0
    je .loopdone
    call print
    jmp .loop
.loopdone:
    ret

clear_screen:
    ; clean up di and al
    mov al, ' '
    mov di, 0

    ; change color to backgorund color
    mov ah, BACKGROUND_COLOR

    ; builtin loop for us
    mov cx, SCREEN_SIZE
    rep stosw

    ; reset and return
    mov di, 0
    ret

cursor_hide:
    ; set attrs
    mov ah, CURSOR_TYPE_FUNC
    mov ch, INVISIBLE_CURSOR
    mov cl, 0x00

    ; interrupt
    int BIOS_INTERRUPT

    ret

math_center:
    ; clear register
    xor ch, ch

    ; load data
    mov ax, SCREEN_X

    ; calculate blank length
    sub ax, cx

    ; we dont need shift because it automatically is half ast each char in VGA memory is 2 bytes
    ; but we do have to round for an odd number
    ; DI = 2 * floor((SCREEN_X - len) / 2) but instead of /2 we are doing:
    ; DI = 2 * round(SCREEN_X - len)
    and ax, MATH_XOR_ROUND

    ; return
    mov di, ax
    ret

get_string_length:
    ; this function is kinda slow but it does the job optimize later

    ; setup
    push si ; lets not destory original value
    xor cx, cx

.loop:
    ; simple loop

    lodsb

    ; compare first
    cmp al, 0
    je .done

    ; re loop
    inc cx
    jmp .loop

.done:
    ; pop and return 
    pop si
    ret

print:
    ; basic print function (literally one instruction)
    stosw
    ret

load_kernel:
    ; ignore es
    mov bx, KERNEL_ADDR
    xor ax, ax
    mov es, ax

    ; config
    mov ah, SECTOR_READ
    mov al, 2
    mov cl, 2
    mov dh, HEAD
    mov ch, CYLINDER

    ; pop the orginally pushed dl
    pop dx

    int BIOS_WRITE

    ; jump if errors
    jc disk_error

    jmp 0x0000:KERNEL_ADDR

disk_error:
    inc bl

    ; print an error message
    call cursor_hide
    call clear_screen

    mov si, erro

    mov ah, ERROR_TEXT

    ; now print it and hang
    call print_string

    jmp hang

hang:
    jmp $ ; loop forever

; --- DATA ---

; strings
hello: db "Going to 32 bit protected mode...", 0
erro: db "AN ERROR OCCURED", 0

; check code size
%assign CODE_SIZE ($ - $$)
%warning The bootloader size is: CODE_SIZE bytes.

times (PADDING - 2) - ($ - $$) db 0
dw MAGIC_NUMBER ; magic number