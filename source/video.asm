include "hardware.inc"
include "macros.inc"

section "Video", rom0

; Copy font to appropriate place in VRAM
CopyFont::
    ld hl, FontTiles
    ld bc, FontTiles.end - FontTiles
    ld de, VRAM_TILE_BLOCK_2 - (16 * 16 * 3) ; at the end of block 1
                                                ; 16 bytes per tile * 16 columns * 3 rows
    jp Memcpy

; a value
; c column
; b row
PrintHex::
    call CalculateVramPos

    ld d, a
    swap a
    and a, $0f
    or a, $d0
    ld [hli], a
    ld a, d
    and a, $0f
    or a, $d0
    ld [hl], a

    ret

PrintText::
    push hl
    call CalculateVramPos
    pop de
.loop
    ld a, [de]
    or a, a ;check 0
    ret z
    inc de
    ld [hli], a
    jr .loop


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

; Copies an entire visible screen from hl to VRAM
CopyScreenData::
    ld c, DISPLAY_COLUMNS
    ld b, DISPLAY_ROWS 
    ld de, VRAM_SCREEN_0 
.loop
    ld a, [hli]
    ld [de], a ; copy over
    inc de

    dec c
    jr nz, .loop ; not at column 0 yet, keep going
    ; at column 0, are we done with rows yet?
    dec b
    ret z ; if we are, we're done.
    ; otherwise...
    ld c, DISPLAY_COLUMNS

    ld a, TILEMAP_COLUMNS - DISPLAY_COLUMNS
    add a, e
    ld e, a
    jr nc, .loop
    inc d  ; add TILEMAP_COLUMNS - DISPLAY_COLUMNS to de

    jr .loop ; keep going.

section "Font data", rom0
FontTiles:
incbin "font.2bpp"
.end
