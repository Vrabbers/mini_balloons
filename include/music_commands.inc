; see source/music/insts.txt

if !def(MUSIC_COMMANDS_INC)
def MUSIC_COMMANDS_INC equ 1

include "notes.inc"

macro measure
static_assert \1 | \2 | \3 | \4 < 128, "measure id too large"
        db \1, \2, \3, \4
endm

def SONG_JUMP_OPCODE equ %1000_0000
macro jump
assert (\1 - @ <= 127) && (\1 - @ >= -128), "song jump destination too far"
        db SONG_JUMP_OPCODE, \1 - @
endm

def SONG_WAVEPTR_OPCODE equ %1100_0000
macro waveptr
static_assert \1 >= 0 && \1 <= 3, "waveptr number must be between 0 and 3"
        db SONG_WAVEPTR_OPCODE | \1, low(\2), high(\2)
endm

def SONG_ENDSONG_OPCODE equ %1111_1111
def endsong equs "db SONG_ENDSONG_OPCODE"

def MEASURE_16BIT_MASK equ %1111_1000

def MEASURE_N_OPCODE equ %1000_0000
macro n
static_assert high(\1) <= 7
        db MEASURE_N_OPCODE | high(\1), low(\1)
endm

def MESAURE_LEN_OPCODE equ %1100_0000
macro len
        db MESAURE_LEN_OPCODE, \1
endm

def MEASURE_8BIT_MASK equ %1111_1100
def MEASURE_DUTY_OPCODE equ %0100_0000
macro duty
if \1 == 12
        db MEASURE_DUTY_OPCODE | %00
elif \1 == 25
        db MEASURE_DUTY_OPCODE | %01
elif \1 == 50
        db MEASURE_DUTY_OPCODE | %10
elif \1 = 75
        db MEASURE_DUTY_OPCODE | %11
else
        fail "invalid duty cycle"
endc
endm

def MEASURE_WAVE_OPCODE equ %0010_0000
macro wave
static_assert \1 >= 0 && \1 <= 3, "wave number must be between 0 and 3"
        db MEASURE_WAVE_OPCODE | \1
endm

def end equs "db 0"

endc ; if !def(MUSIC_COMMANDS_INC)

