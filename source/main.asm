include "hardware.inc"
include "macros.inc"

section "Main", rom0

Init::
        call DisableLCD

        xor a
        ld [rAUDENA], a ; Disable audio

        ld bc, $a000 - $8000
        ld hl, $8000
        call Memset ; Clear VRAM

        ld b, $e0 - $c0
        ld hl, $c000
        call Memset ; Clear WRAM

        ld c, $fffc - $ff80
        ld hl, $ff80
        call Memset ; Clear HRAM (except return address)

        call CopyFont

        call InitializeTitleScreen ; initialize title screen state

        ; FALLTHROUGH to Main

Main::
        call ReadJoypad

        ld a, [wGameState]
        or a
        call z, TitleScreenLoop
        jr :+
        cp GAME_STATE_GAME
        call z, GameLoop

:
        ld a, 1
        ldh [hMainDone], a

        call SoftVBlankWait

        ld hl, wFrameCounter
        inc [hl]
        jr Main

VBlankHandler::
        ld a, 1
        ldh [hWasVBlankInterrupt], a
        ldh a, [hMainDone]
        or a
        ret z ; main is not done, end

.mainDone
        ; main is done, do everything we need to now.
        ld a, [wGameState]
        or a ; cp GAME_STATE_TITLESCREEN
        call z, TitleScreenVBlank
        jr :+
        cp GAME_STATE_GAME
        call z, GameVBlank

:
        ret