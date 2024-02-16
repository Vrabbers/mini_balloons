include "hardware.inc"

section "Joypad", rom0

ReadJoypad::
        ldh a, [hJoypad]
        cpl
        ld c, a ; c holds NOT previous joypad

        ld a, P1F_GET_DPAD
        ldh [rP1], a
rept 6
        ldh a, [rP1]
endr
        cpl
        swap a
        and $f0
        ld b, a

        ld a, P1F_GET_BTN
        ldh [rP1], a
rept 6
        ldh a, [rP1]
endr
        cpl
        and $0f
        or b

        ldh [hJoypad], a
        and a, c ; c was NOT previous joypad. now, a = ~prev & current
        ldh [hJoypadPressed], a
        ret

