include "macros.inc"
include "hardware.inc"

section "Software interrupts", rom0[$00]
        ds $38 - @, $ff

section "rst $38 handler", rom0[$38]
        jp CrashHandler

section "VBlank interrupt handler", rom0[$40]
        call VBlankHandler
        reti

; All other interrupts should just crash
section "STAT interrupt handler", rom0[$48]
        rst $38

section "Timer interrupt handler", rom0[$50]
        rst $38

section "Serial interrupt handler", rom0[$58]
        rst $38

section "Joypad interrupt handler", rom0[$60]
        rst $38

section "Header", rom0[$0100]
        jp Init

        ds $150 - @, $00 ; Leave space for header
