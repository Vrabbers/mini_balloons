include "hardware.inc"
include "constants.inc"
include "macros.inc"

section "Crash", rom0
CrashHandler::
        ld b, b

        ld sp, $fffe ; set sp to good value
        call BusyVBlankWait
        COORDS de, $01, $01
        ld hl, .text
        call PrintText

        di
        jr @ ; halt execution

.text
        db "bonkers!", 0

