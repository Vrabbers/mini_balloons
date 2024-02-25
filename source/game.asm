include "hardware.inc"
include "constants.inc"

section "Game", rom0
InitializeGame::
        ld a, %11_10_01_00
        ldh [rBGP], a ; set palette

        xor a
        ld bc, $a000 - $8000
        ld hl, $8000
        call Memset ; Clear VRAM

        ld bc, $fe9f - $fe00
        ld hl, $fe00
        call Memset ; Clear OAM

        ; Turn lcd back on
        ld a, LCDCF_ON | LCDCF_BGON | LCDCF_OBJON
        ldh [rLCDC], a

        ld a, IEF_VBLANK
        ldh [rIE], a

        ld hl, wwMainCallback
        ld [hl], low(GameLoop)
        inc hl
        ld [hl], high(GameLoop)

        ld hl, wwVBlankCallback
        ld [hl], low(GameVBlank)
        inc hl
        ld [hl], high(GameVBlank)
        reti

GameLoop::
        ret

GameVBlank::
        ret