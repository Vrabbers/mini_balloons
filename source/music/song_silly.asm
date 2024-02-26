include "music_commands.inc"

def sixteenth equ 8
def eigth equ sixteenth * 2
def quarter equ eigth * 2
def half equ quarter * 2
def whole equ half * 2

section "Silly Song Data", rom0
SillySong::
        waveptr 0, .wave0
.loop
        dw .m1c1, .m1c2, .m1c3, .null
        dw .m2c1, .m2c2, .m2c3, .null
        jump .loop

.wave0
        db $00, $00, $00, $00, $00, $00, $00, $00, $00
        db $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff

.null
        end

.m1c1
        duty 50
        len sixteenth
        n C4
        n C#4
        n D4
        n D#4

        n E4
        n F4
        n F#4
        n G4

        n G#4
        n A4
        n A#4
        n B4

        len quarter
        n C5
        end

.m1c2
        duty 50
        len whole
        n C3
        end

.m1c3
        wave 0
        len quarter
        n C3
        n C4
        n C3
        n C4
        end

.m2c1
        duty 50
        len sixteenth
        n C#4
        n D4
        n D#4
        n E4

        n F4
        n F#4
        n G4
        n G#4

        n A4
        n A#4
        n B4
        n C5

        len quarter
        n G#3
        end

.m2c2
        duty 50
        len whole
        n F3
        end

.m2c3
        wave 0
        len quarter
        n C#3
        n C#4
        n C#3
        n C#4
        end
