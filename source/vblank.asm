include "hardware.inc"

section "VBlank", rom0

BusyVBlankWait::
    ldh a, [rLY]
    cp a, 144
    jr c, BusyVBlankWait
    ret

VBlankHandler::
    ldh a, [hMainDone]
    or a, a
    jr nz, .mainDone
    reti ; main is not done, bail out.

.mainDone
    ; main is done, do everything we need to now.

    reti
