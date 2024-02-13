include "hardware.inc"

section "Video", rom0

BusyVBlankWait:
    ldh a, [rLY]
    cp a, 144
    jr c, BusyVBlankWait
    ret

VBlankHandler:
    ld c, hwFrameCounter - $ff00
    ldh a, [$ff00+c]
    ld e, a
    inc c
    ldh a, [$ff00+c]
    ld d, a
    dec c
    inc de
    ld a, e
    ldh [$ff00+c], a
    inc c
    ld a, d 
    ldh [$ff00+c], a
    
    ld bc, $0000
    ld a, d
    call PrintHex
    ld c, $2
    ldh a, [hwFrameCounter]
    call PrintHex
    reti
