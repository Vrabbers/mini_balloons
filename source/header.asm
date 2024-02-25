include "constants.inc"
include "hardware.inc"

; Unused interrupts crash (rst $38).
section "Software Interrupts", rom0[$00]
        ds $38 - @, $ff

section "Software Interrupt $38 Handler", rom0[$38]
        jp CrashHandler

section "VBlank Interrupt Handler", rom0[$40]
        jp VBlankHandler

section "STAT Interrupt Handler", rom0[$48]
        rst $38

section "Timer Interrupt Handler", rom0[$50]
        rst $38

section "Serial Interrupt Handler", rom0[$58]
        rst $38

section "Joypad Interrupt Handler", rom0[$60]
        rst $38

section "Header", rom0[$0100]
Entry:
        jp Main

        ds $150 - @, $00 ; Leave space for header
