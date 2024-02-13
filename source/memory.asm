section "Memory", rom0
; Copies bc bytes from hl to de
Memcpy:
    ld a, c
    or a, b 
    ret z ; End when bc is 0
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    jr Memcpy

; Sets bc bytes to a starting at hl
Memset: 
    ld d, a

:   ld a, c
    or a, b
    ret z
    ld a, d
    ld [hl+], a
    dec bc
    jr :-