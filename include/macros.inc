if !def(MACROS_INC)
def MACROS_INC equ 1

; COORDS reg16, x, y
macro COORDS
        ld \1, $9800 + (\3 * 32) + \2
endm

endc ; if !def(MACROS_INC)
