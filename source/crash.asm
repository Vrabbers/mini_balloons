include "hardware.inc"
include "macros.inc"

section "Crash", rom0
CrashHandler:
    ld bc, $0000
    call BusyVBlankWait
    ld hl, .text
    call PrintText
    ld b, b
    di
:   halt ; halts processor
    nop
    jr :-

.text:
    db "rst $38", 0
