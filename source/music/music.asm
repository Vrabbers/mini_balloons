include "music_commands.inc"
include "hardware.inc"

section "Music Engine Variables", wram0, align[5]
wwSongPC:
        dw

wwSongMeasuresTablePtr:
        dw

wwSongMeasuresPCs:
        ds 4 * 2
.end:

wwWavePtrs:
        ds 4 * 2

wNoteLengths:
        ds 4

wLengthCounters:
        ds 4

section "Music Engine",rom0

; hl holds start of music data.
MusicInit::
        ld a, l
        ld [wwSongPC], a
        ld a, h
        ld [wwSongPC + 1], a
.seekMeasureTableLoop
        ld a, [hli]
        cp SONG_ENDSONG_OPCODE
        jr z, .foundEnd
        and %1111_1100
        cp SONG_WAVEPTR_OPCODE
        jr z, .waveptrCommandSkip2
        cp SONG_JUMP_OPCODE
        jr z, .jumpCommandSkip1
        ; must be four measure commands, skip 3
        inc hl
.waveptrCommandSkip2
        inc hl
.jumpCommandSkip1
        inc hl
        jr .seekMeasureTableLoop
.foundEnd
        ; hl already past end, write to wwSongMeasuresTablePtr
        ld a, l
        ld [wwSongMeasuresTablePtr], a
        ld a, h
        ld [wwSongMeasuresTablePtr + 1], a

        ; tail call
        jp MusicSongDoTick.doCommands ; skip the part where it verifies that all channels have stopped.

MusicSongDoTick:
        ld c, 4 * 2
        ld hl, wwSongMeasuresPCs
        xor a
.checkAllZeroLoop
        ld a, [hli]
        or a
        ret nz ; if any bytes are non-zero, we can quit already
        dec c
        jr nz, .checkAllZeroLoop
.doCommands
        ; all are zero, so we have to do commands
        ld hl, wwSongPC
        ld a, [hli]
        ld h, [hl]
        ld l, a
.cmdLoop
        ld a, [hl] ; dont autoincrement yet
        bit 7, a
        jr z, .readMeasures ; measure ids must have highest bit 0
        inc hl ; increment hl now
        bit 6, a
        jr nz, .wavePtrCode ; wave ptr opcode is 1100 00ww
.jumpCode
        ld c, [hl]
        ld a, c
        add a
        sbc a ; sign extend
        ld b, a
        add hl, bc
        jr .cmdLoop
.wavePtrCode
        and a, %0000_0011
        add a
        add a, low(wwWavePtrs)
        ld c, a
        ld b, high(wwWavePtrs) ; set up pointer to wwWavePtrs entry in bc

        ld a, [hli]
        ld d, [hl] ; wave ptr is now in "da"
        inc hl

        ld [bc], a
        inc c
        ld a, d
        ld [bc], a ; store da in bc

        jr .cmdLoop
.readMeasures
        ld de, wwSongMeasuresPCs
.readMeasuresLoop
        ld a, [hli] ; read measure id
        add a ; double
        ld c, a ; store in C
        push hl ; save hl ([wwSongPC]) for later

        ld hl, wwSongMeasuresTablePtr
        ld a, [hli]  ; \
        ld h, [hl]   ; / ha = [wwSongMeasuresTablePtr]

        add a, c    ; \
        jr nc, :+   ; |
        inc b       ; / add c (pointer offset) to ba

:       ; ha now has the pointer to the measure pointer table entry
        ld l, a
        ld a, [hli]
        ld b, [hl]

        pop hl
        ; ba has the pointer to the measure
        ; de has the pointer to the appropriate wwSongMeasurePC entry
        ld [de], a
        inc e
        ld a, b
        ld [de], a ; [de] = ba
        inc e

        ld a, low(wwSongMeasuresPCs.end)
        cp e
        jr nz, .readMeasuresLoop ; if we're still not at the end, do again

        ; store hl in wwSongPC
        ld a, l
        ld b, h
        ld hl, wwSongPC
        ld [hli], a
        ld [hl], b
        ret
