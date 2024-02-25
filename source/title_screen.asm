include "hardware.inc"
include "constants.inc"
include "macros.inc"

section "Title Screen Variables", wram0
wFade: db

section "Title Screen", rom0
InitializeTitleScreen::
        ld a, %11_10_01_00
        ldh [rBGP], a ; set palette

        ld a, -15
        ld [wFade], a ; start fade timer

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

        reti ; return and enable interrupts
        ; only enable interrupts after the vblank callback has been properly set!

TitleScreenLoop::
        ld a, [wFade]
        or a
        jr nz, .fade ; fade counter is not 0, go to fade routine
        ldh a, [hJoypadPressed]
        cp JOYPAD_START
        ret nz ; no start, done
        ld a, 1
        ld [wFade], a ; start fade animation timer
        ret
.fade
        ; we have wFade on a
        cp 15
        jr z, .endTitleScreen
        inc a
        ld [wFade], a
        ret
.endTitleScreen
        call DisableLCD
        jp InitializeGame


TitleScreenVBlank::
        ld a, [wFrameCounter]
        ; print "START! or clear it"
        bit 5, a
        jr nz, .prEmpty
        ld hl, .pressStart
        jr .cont
.prEmpty
        ld hl, .empty
.cont
        COORDS de, $01, $0e
        call PrintText
.doFade
        ld a, [wFade]
        or a
        bit 7, a
        jr z, :+
        cpl ; if wFade is negative, make it positive
        inc a
:
        sra a
        and %0000_0110 ; a / 4 * 2 without lsb
        ld b, %11_10_01_00
        jr z, .endLoop ; handle 0 case. z flag is still set from and up there
.loop
        sla b
        dec a
        jr nz, .loop
.endLoop
        ld a, b
        ldh [rBGP], a
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
