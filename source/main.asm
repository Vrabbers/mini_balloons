include "hardware.inc"
include "macros.inc"

section "Main", rom0

Init::
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
    call CopyFont

    call InitializeTitleScreen ; initialize title screen state

    ; FALLTHROUGH to Main

Main::
    ;increment wwFrameCounter
    ld hl, wwFrameCounter
    inc [hl]
    jr nz, :+
    inc hl
    inc [hl]
:

    ld a, [wGameState]
    or a
    call z, TitleScreenLoop

    ld a, 1
    ldh [hMainDone], a

    halt
    jp Main