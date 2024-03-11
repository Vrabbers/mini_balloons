include "music_commands.inc"
include "hardware.inc"

section "Music Engine Variables", wram0, align[5]
wwSongPC:
        dw

wwSongMeasuresPCs:
        ds 4 * 2
.end:

wNoteLengths:
        ds 4

wLengthCounters:
        ds 4

wwSongMeasuresTablePtr:
        dw

wwWavePtrs:
        ds 4 * 2

section "Music Engine Scratch Space", hram
hChannelRegisterOffset: db

hLengthScratch: db
hCommandScratch: db


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
        cp SONG_MVOL_OPCODE
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
        
        xor a
        ld hl, wLengthCounters
        ld [hli], a
        ld [hli], a
        ld [hli], a
        ld [hli], a ; zero out length counters for proper MusicMeasuresDoTick

        ; tail call
        jr MusicSongDoTick.doCommands ; skip the part where it verifies that all channels have stopped.



MusicSongDoTick::
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
        cp SONG_MVOL_OPCODE
        jr z, .mvolCode
        ;fallthrough to jump code
.jumpCode
        ld c, [hl]
        ld a, c
        add a
        sbc a ; sign extend
        ld b, a
        add hl, bc
        jr .cmdLoop
.mvolCode
        ld a, [hli]
        ldh [rNR50], a
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
        inc h       ; / add c (pointer offset) to ha

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



MusicMeasuresDoTick::
        ld c, 0 ; current channel in c
.mainLoop
        ld h, high(wLengthCounters)
        ld a, low(wLengthCounters)
        add a, c
        ld l, a
.nextChannel
        ld a, [hl]
        or a
        jr z, .continue ; length counter is zero means we need to process this measure
        dec [hl] ; if not we decrement the length counter
        inc c ; increment which channel
        ld a, c
        cp 4 ; if it's 4,
        ret z ; we're done
        inc l ; not 4, go again
        jr .nextChannel
.continue
        ld a, low(wwSongMeasuresPCs)
        add a, c
        add a, c ; pointer offset without clobbering c
        ld l, a ; holds pointer to entry in wwSongMeasuresPCs
        push hl ; save this for later
        ld a, [hli]
        ld h, [hl]
        ld l, a
        or h
        jr z, .endChannel ; if the entry is 0000, ignore channel
        ; hl holds what is at the entry
        ; calculate offset for register
        ld a, c
        add a
        add a ; a = c * 4
        add a, c ; a = c * 4 + c = c * 5
        add a, low(rNR10)
        ldh [hChannelRegisterOffset], a ; store the low byte of the address of the first relevant register of the channel we're processing
.doCommandLoop
        ld a, [hli]
        bit 7, a
        jr z, .byteCommand
        ; fallthrough
.wordCommand
        ld b, [hl]
        inc hl
        cp MEASURE_LEN_OPCODE
        jr z, .lenCommand
        cp MEASURE_ENV_OPCODE
        jr z, .envCommand
; fallthrough to note
.noteCommand
        ldh [hCommandScratch], a
        ; b saved
        call .setLengthCounter
        ldh a, [hCommandScratch]
        ld e, b
        ld d, a

        ld b, c ; save channel no for later
        ldh a, [hChannelRegisterOffset]
        add a, 3 ; get period low from offset
        ld c, a
        ld a, e
        ldh [$ff00+c], a ;rNRx3
        ld a, d
        inc c
        ld [$ff00+c], a ;rNRx4, already has high bit set so it already triggers

        ld c, b ; restore channel
        jr .endChannel
.envCommand
        ldh a, [hChannelRegisterOffset]
        add 2
        ld d, c
        ld c, a
        ld a, b
        ldh [$ff00+c], a
        ld c, d
        jr .doCommandLoop
.lenCommand
        ld d, high(wNoteLengths)
        ld a, low(wNoteLengths)
        add a, c
        ld e, a
        ld a, b
        ld [de], a
        jr .doCommandLoop
.endChannel
        ld a, l
        ld b, h
        pop hl ; pops pointer to wwSongMeasurePCs pushed earlier
        ld [hli], a
        ld [hl], b
        inc c
        ld a, 4
        cp c
        jr nz, .mainLoop
        ret ; no more channels to process
.byteCommand
        or a ; zero
        jr z, .endCommand
        cp MEASURE_R_OPCODE
        jr z, .rCommand
        ldh [hCommandScratch], a
        and a, MEASURE_8BIT_MASK
        cp MEASURE_DUTY_OPCODE
        jr z, .dutyCommand
        cp MEASURE_WAVE_OPCODE
        jr z, .waveCommand
        cp MEASURE_WVOL_OPCODE
        jr z, .wvolCommand
.endCommand
        ld hl, 0
        jr .endChannel
.rCommand
        call .setLengthCounter
        jr .endChannel
.dutyCommand
        call .doDutyCommand
        jr .doCommandLoop
.waveCommand
        call .doWaveCommand
        jr .doCommandLoop
.wvolCommand
        ldh a, [hCommandScratch]
        rrca
        rrca
        rrca
        ldh [rNR32], a
        jr .doCommandLoop
.setLengthCounter
        ld d, high(wNoteLengths)
        ld a, low(wNoteLengths)
        add a, c
        ld e, a
        ld a, [de] ; de = wNoteLengths + c
        ldh [hLengthScratch], a ; save for later
        ld a, low(wLengthCounters)
        add a, c
        ld e, a
        ldh a, [hLengthScratch]
        ld [de], a ; de = wLengthCounters + c
        ret
.doDutyCommand
        ld b, c ; save channel
        ldh a, [hChannelRegisterOffset]
        add a, 1 ; rNRx1
        ld c, a
        ldh a, [hCommandScratch]
        and a, ~MEASURE_8BIT_MASK
        rrca
        rrca ; value to be written to rNRx1
        ldh [$ff00+c], a
        ld c, b ;restore channel
        ret
.doWaveCommand
        ldh a, [hCommandScratch]
        and a, ~MEASURE_8BIT_MASK
        ld b, a
        xor a
        ldh [rNR30], a ; turn DAC off
        ld a, low(wwWavePtrs)
        add a, b
        add a, b
        push hl
        push bc
        ld l, a
        ld h, high(wwWavePtrs)
        ld a, [hli]
        ld h, [hl]
        ld l, a
        ld de, _AUD3WAVERAM
        ld bc, $0010
        call Memcpy
        pop bc
        pop hl
        ld a, $80
        ldh [rNR30], a ; turn DAC back on
        ret