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
        ldh [rLCDC], a

        ei
        ld a, IEF_VBLANK
        ldh [rIE], a ; Enable VBlank interrupt

        ld hl, wwMainCallback
        ld [hl], low(TitleScreenLoop)
        inc hl
        ld [hl], high(TitleScreenLoop)

        ld hl, wwVBlankCallback
        ld [hl], low(TitleScreenVBlank)
        inc hl
        ld [hl], high(TitleScreenVBlank)

        ret

TitleScreenLoop::
        ldh a, [hJoypadPressed]
        cp JOYPAD_START
        ret nz ; return on no start
        call DisableLCD
        jp InitializeGame

TitleScreenVBlank::
        ld a, [wFrameCounter]
        ld b, a
        and %0001_1111
        jr nz, .noPrint

        ; print "START! or clear it"
        ld a, b
        bit 5, a
        jr nz, .prEmpty
        ld hl, .pressStart
        jr .cont
.prEmpty
        ld hl, .empty
.cont
        ld bc, $0d01
        call PrintText

.noPrint
        ret
.pressStart
        db "start!", 0
.empty
        db "      ", 0

TitleScreenTilemap:
incbin "title.map"
.end

TitleScreenTiles:
incbin "title.2bpp"
.end
