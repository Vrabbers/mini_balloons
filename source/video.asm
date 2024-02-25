include "hardware.inc"
include "constants.inc"

section "Video", rom0

; note: disables interrupts
DisableLCD::
        di
        call BusyVBlankWait
        xor a
        ldh [rLCDC], a ; disable lcd in vblank
        ret

;; Waits for VBlank with a busy loop
BusyVBlankWait::
        ldh a, [rLY]
        cp a, 144
        jr c, BusyVBlankWait
        ret

SoftVBlankWait::
        halt
        nop
        ld a, [wWasVBlankInt]
        or a
        jr z, SoftVBlankWait ; wasn't vblank interrupt
        xor a
        ld [wWasVBlankInt], a
        ret

; Copy font to appropriate place in VRAM
CopyFont::
        ld de, FontTiles
        ld bc, FontTiles.end - FontTiles
        ld hl, VRAM_TILE_BLOCK_2 - (16 * 16 * 3) ; at the end of block 1
                                                 ; 16 bytes per tile * 16 columns * 3 rows
.loop:  ld a, c
        or a, b 
        ret z ; End when bc is 0
        ld a, [de]
        ld [hli], a
        ld [hli], a ; makes 1bpp font data into 2bpp
        inc de
        dec bc
        jr .loop

; Prints null-terminated string from hl to memory at de
PrintText::
        ld a, [hli]
        or a ;check 0
        ret z
        ld [de], a
        inc de
        jr PrintText

CalculateVramPos::
        ld d, $00
        ld a, b

        add a
        add a
        add a
        add a
        rl d
        add a
        rl d ; assuming e > 32, multiplies de by 32 (no of columns)
        ld e, a

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
incbin "font.1bpp"
.end

