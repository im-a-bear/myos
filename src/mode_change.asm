%include "src/constants.inc"
%include "src/utils/bitmask.inc"

[org KERNEL_ADDR]
[bits 16] ; start in 16 bit real mode

; mov byte [0xB800], 'X'
; mov byte [0xB801], 0x1F

main:
    call enable_a20

    ; disable interrupts
    cli

    ; tell the cpu about our gdt
    lgdt [gdtc]

    ; do a general registor byte flip to cr0
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; now far jump
    jmp GDT_ENTRY_1:protected_mode_stc

; implelemnt this later
; enable_a20:
; .old_school:
;     ; why do we have to do this???
;     in al, KEYBOARD_STATUS_PORT
;     test al, KEYBOARD_A20_PORT
;     jnz .old_school
;
; .new_school:
enable_a20:
    in al, SYSTEM_CONTROL ; input
    ; change a20 bit
    or al, SET_BIT_2_ON ; make sure that bit 1 is not 1 if so then computer will be hard reboot
    out SYSTEM_CONTROL, al ; output
    ret

hang:
    hlt
    jmp hang


; this is self explanatory
gdt:
    dq GDT_NULL
    dq GDT_CODE
    dq GDT_DATA
gdti:

gdtc:
    dw gdti - gdt - 1
    dd gdt

[bits 32] ; protected mode
protected_mode_stc:
    ; set up stack, evrything
    mov ax, GDT_ENTRY_2
    mov ds, ax
    mov es, ax
    mov ss, ax

    ; call stack
    mov esp, CALL_STACK

    mov dword [0xB8000], 0x2F4B2F4F
    
    jmp hang

times (KERNEL_SECTORS * SECTOR_LENGTH) - ($ - $$) db 0

%assign CODE_SIZE ($ - $$)
%warning The kernel size is: CODE_SIZE bytes.
