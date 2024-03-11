include "music_commands.inc"

def grace equ 3
def sixteenth equ 8
def eigth equ sixteenth * 2
def quarter equ eigth * 2
def half equ quarter * 2
def whole equ half * 2

section "Silly Song Data", rom0

SillySong::
        waveptr 0, .wave0
        mvol 7, 7
        measure 01, 02, 16, 00
.loop
        mvol 5, 7
        measure 04, 05, 06, 00
        mvol 7, 5
        measure 07, 08, 03, 00
        mvol 5, 7
        measure 04, 09, 06, 00
        mvol 7, 5
        measure 07, 08, 03, 00
        mvol 5, 7
        measure 10, 11, 12, 00
        mvol 7, 5
        measure 13, 14, 15, 00
        jump .loop
        endsong
.measurePointers
        dw $0000 ; 0
        dw .introPulse1, .introPulse2, .lowAWave ; 1, 2, 3
        dw .fig1pulse1, .fig1pulse2, .highAWave ; 4, 5, 6
        dw .fig2pulse1, .fig2pulse2 ; 7, 8
        dw .fig3pulse2 ; 9
        dw .fig4pulse1, .fig4pulse2, .lowGWave ; 10, 11, 12
        dw .fig5pulse1, .fig5pulse2, .highGWave ; 13, 14, 15
        dw .lowAWaveIntro ; 16

.introPulse1
        env 7, up, 1
        duty 75
        len half
        r
        n C4
        end
.introPulse2
        env 5, up, 1
        duty 50
        len quarter
        r
        len quarter + half
        n E3
        end
.lowAWaveIntro
        wave 0
        wvol 1
.lowAWave
        len whole
        n A3
        end


.fig1pulse1
        len sixteenth
        n A4
        n A4
        len eigth
        n C5
        n D5
        n E5
        len quarter
        n D5
        n A4
        end
.fig1pulse2
        len quarter
        n E4
        n D4
        n E4
        n C4
        end
.highAWave
        len whole
        n A4
        end


.fig2pulse1
        len sixteenth
        n A4
        n A4
        len eigth
        n F4
        len quarter - grace
        n E4
        len 4
        n G4
        len half
        n A4
        end
.fig2pulse2
        len quarter
        n E3
        n C3
        n E3
        n C3
        end


.fig3pulse2
        len quarter
        n E4
        n C4
        n E4
        n C4
        end


.fig4pulse1
        len sixteenth
        n A4
        n A4
        len eigth
        n E4
        n G4
        n A4
        len quarter
        n D5
        n A4
        end
.fig4pulse2
        len quarter
        n G3
        n D3
        n G3
        n D3
        end
.lowGWave
        len whole
        n G3
        end

.fig5pulse1
        len sixteenth
        n A4
        n A4
        len eigth
        n C5
        len quarter - grace
        n E5
        len 4
        n G5
        len half
        n A5
        end
.fig5pulse2
        len quarter
        n G4
        n D4
        n G4
        n D4
        end
.highGWave
        len whole
        n G4
        end

.wave0
        db $89, $ab, $cd, $ef, $ff, $ff, $ff, $e9
        db $71, $00, $00, $00, $01, $23, $45, $67