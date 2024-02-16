include "hardware.inc"
include "macros.inc"

section "Crash", rom0
CrashHandler::
        ld b, b

        ld sp, $fffe ; set sp to good value
        call BusyVBlankWait
        ld b, $01
        ld c, b ; x=1, y=1
        ld hl, .text
        call PrintText

        di
        jr @ ; halt execution

.text
        db "rst $38 crash", 0

