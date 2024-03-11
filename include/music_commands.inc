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

def SONG_MVOL_OPCODE equ %1010_0000
macro mvol
static_assert \1 >= 0 && \1 <= 7 && \2 >= 0 && \2 <= 7, "master volume must be between 0 and 7"
        db SONG_MVOL_OPCODE, (\1 << 4) | \2
endm

def SONG_ENDSONG_OPCODE equ %1111_1111
def endsong equs "db SONG_ENDSONG_OPCODE"

def MEASURE_16BIT_MASK equ %1111_1000

def MEASURE_N_OPCODE equ %1000_0000
macro n
static_assert high(\1) <= 7
        db MEASURE_N_OPCODE | high(\1), low(\1)
endm

def MEASURE_LEN_OPCODE equ %1100_0000
macro len
static_assert \1 >= 0 && \1 <= 255, "length must be between 0 and 255"
        db MEASURE_LEN_OPCODE, \1 - 1
endm

def MEASURE_ENV_OPCODE equ %1010_0000
def up equ $08
def down equ 00
macro env
static_assert \1 >= 0 && \1 <= 15, "volume must be in range [0, 15]"
static_assert \2 == down || \2 == up, "envelope direction must be up or down"
static_assert \3 >= 0 || \3 <= 7, "envelope speed must be in range [0, 7]"
        db MEASURE_ENV_OPCODE, (\1 << 4) | \2 | \3
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
elif \1 == 75
        db MEASURE_DUTY_OPCODE | %11
else
        fail "invalid duty cycle"
endc
endm

def MEASURE_R_OPCODE equ %0000_0001
def r equs "db MEASURE_R_OPCODE"

def MEASURE_WAVE_OPCODE equ %0010_0000
macro wave
static_assert \1 >= 0 && \1 <= 3, "wave number must be between 0 and 3"
        db MEASURE_WAVE_OPCODE | \1
endm

def MEASURE_WVOL_OPCODE equ %0110_0000
macro wvol
static_assert \1 >= 0 && \1 <= 3, "wave volume must be between 0 and 3"
        db MEASURE_WVOL_OPCODE | \1
endm

def end equs "db 0"

endc ; if !def(MUSIC_COMMANDS_INC)

