include "hardware.inc"
include "macros.inc"

section "Main", rom0

Main::
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

        ; FALLTHROUGH to MainLoop

MainLoop::
        call ReadJoypad

        ld hl, wwMainCallback
        ld a, [hli]
        ld e, a
        ld d, [hl]
        ld h, d
        ld l, e
        ld de, .cont
        push de
        jp hl
.cont
        ld a, 1
        ld [wMainDone], a

        call SoftVBlankWait

        ld hl, wFrameCounter
        inc [hl]
        jr MainLoop

VBlankHandler::
        ld a, 1
        ld [wWasVBlankInt], a
        ld a, [wMainDone]
        or a
        ret z ; main is not done, end

.mainDone
        ; main is done, do everything we need to now.
        ld hl, wwVBlankCallback
        ld a, [hli]
        ld e, a
        ld d, [hl]
        ld h, d
        ld l, e
        ld de, .cont
        push de
        jp hl

.cont
        ret