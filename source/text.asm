include "macros.inc"

section "Text", rom0

CalculateVramPos:
    ld d, $00
    ld e, b

    sla e
    sla e
    sla e
    sla e 
    rl d
    sla e
    rl d ; assuming e > 32, multiplies de by 32 (no of columns)

    ld h, high(VRAM_SCREEN_0)
    ld l, c
    add hl, de
    ret


; a value
; c column
; b row
PrintHex:
    call CalculateVramPos

    ld d, a
    swap a
    and a, $0f
    or a, $d0
    ld [hl+], a
    ld a, d
    and a, $0f
    or a, $d0
    ld [hl], a

    ret

PrintText:
    push hl
    call CalculateVramPos
    pop de
.loop:
    ld a, [de]
    or a, a
    ret z
    inc de
    ld [hl+], a
    jr .loop

section "Font data", rom0
FontTiles:
incbin "font.2bpp"
.end: