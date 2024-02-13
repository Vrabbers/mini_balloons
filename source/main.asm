include "hardware.inc"
include "macros.inc"

section "Main", rom0
Main:
    halt
    nop
    jr Main

Init:
    di

    call BusyVBlankWait

    xor a
    ldh [rLCDC], a ; disable lcd in vblank
    ld [rAUDENA], a ; Disable audio

    ld bc, $a000 - $8000
    ld hl, $8000
    call Memset ; Clear VRAM

    ld b, $e0 - $c0
    ld hl, $c000
    call Memset ; Clear WRAM

    ld bc, $fffc - $ff80
    ld hl, $ff80
    call Memset ; Clear HRAM (except return address)

    ld a, %11_10_01_00
    ldh [rBGP], a ; set palette

    ; Copy tiles over
    ld hl, TitleScreenTiles
    ld bc, TitleScreenTiles.end - TitleScreenTiles
    ld de, VRAM_TILE_BLOCK_2 ; Into block 2 as 
    call Memcpy

    ; Copy font over
    ld hl, FontTiles
    ld bc, FontTiles.end - FontTiles
    ld de, VRAM_TILE_BLOCK_2 - (16 * 16 * 3) ; at the end of block 1
                                             ; 16 bytes per tile * 16 columns * 3 rows
    call Memcpy

    ; Copy tile map data
    ld hl, TitleScreenTilemap
    call CopyScreenData

    ; Turn lcd back on
    ld a, LCDCF_ON | LCDCF_BGON
    ld [rLCDC], a

    ei
    ld a, IEF_VBLANK
    ldh [rIE], a ; Enable VBlank interrupt
    jp Main

; Copies an entire visible screen from hl to VRAM
CopyScreenData:
    ld c, DISPLAY_COLUMNS
    ld b, DISPLAY_ROWS 
    ld de, VRAM_SCREEN_0 
.loop:
    ld a, [hl+]
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

section "Title screen data", rom0
TitleScreenTilemap:
incbin "title.map"
.end:

TitleScreenTiles:
incbin "title.2bpp"
.end: