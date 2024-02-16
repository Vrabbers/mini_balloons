include "hardware.inc"
include "macros.inc"

section "Title screen", rom0

InitializeTitleScreen::
    ld a, %11_10_01_00
    ldh [rBGP], a ; set palette

    ; Copy tiles over
    ld hl, TitleScreenTiles
    ld bc, TitleScreenTiles.end - TitleScreenTiles
    ld de, VRAM_TILE_BLOCK_2 ; Into block 2 as 
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

    ld hl, wGameState
    ld [hl], GAME_STATE_TITLESCREEN

    ret

TitleScreenLoop::
    ld hl, $dfff
    inc [hl]
    ret

TitleScreenTilemap:
incbin "title.map"
.end
    
TitleScreenTiles:
incbin "title.2bpp"
.end