
section "Memory", rom0

; Calls routine pointed at by HL.
AtHL::
        ld a, [hli]
        ld h, [hl]
        ld l, a
        jp hl ; tail call

; Copies bc bytes from hl to de
Memcpy::
        ld a, c
        or a, b 
        ret z ; End when bc is 0
        ld a, [hli]
        ld [de], a
        inc de
        dec bc
        jr Memcpy

; Sets bc bytes to a starting at hl
Memset::
        ld d, a
.loop
        ld a, c
        or a, b
        ret z
        ld a, d
        ld [hli], a
        dec bc
        jr .loop
