include "hardware.inc"
include "constants.inc"
include "macros.inc"

section "Main", rom0
Main::
        call DisableLCD

        xor a
        ld [rAUDENA], a ; Disable audio
        ld [wMainDone], a
        ld [wFrameCounter], a

        ld bc, $a000 - $8000
        ld hl, $8000
        call Memset ; Clear VRAM

        ld c, $fffc - $ff80
        ld hl, $ff80
        call Memset ; Clear HRAM (except return address)

        call CopyFont

        call InitializeTitleScreen ; initialize title screen state

        ; FALLTHROUGH to MainLoop

MainLoop::
        xor a
        ld [wMainDone], a

        call ReadJoypad

        ld hl, wwMainCallback
        call AtHL

        ld a, 1
        ld [wMainDone], a

        call SoftVBlankWait

        ld hl, wFrameCounter
        inc [hl]
        jr MainLoop

VBlankHandler::
        push af
        ld a, [wMainDone]
        or a
        jr z, .end ; main is not done, end

        ; main is done, do everything we need to now.
        ld hl, wwVBlankCallback
        call AtHL

.end
        ld a, 1
        ld [wWasVBlankInt], a
        pop af
        reti
