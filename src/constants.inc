; --- CONSTANTS ---

; --- DISK SETTINGS --- (really, really important!)
%define HEAD 0
%define CYLINDER 0
%define KERNEL_ADDR 0x7E00
%define KERNEL_SECTORS 2

%define SECTOR_LENGTH 512
%define CALL_STACK 0x90000

; magic constants
%define START_AT 0x7C00
%define PADDING (SECTOR_LENGTH - 2)
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


; PORTS
%define KEYBOARD_STATUS_PORT 0x64
%define KEYBOARD_A20_PORT 2
%define WRITE_OUTPUT_PORT 0xD1
%define SYSTEM_CONTROL 0x92

; GDT
%define GDT_CODE 0x00CF9A000000FFFF
%define GDT_NULL 0x0000000000000000
%define GDT_DATA 0x00CF92000000FFFF
%define GDT_ENTRY_2 0x10
%define GDT_ENTRY_1 0x08
