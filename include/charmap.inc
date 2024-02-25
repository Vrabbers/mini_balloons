if !def(CHARMAP_INC)
def CHARMAP_INC equ 1

newcharmap internal
charmap "0", $d0
charmap "1", $d1
charmap "2", $d2
charmap "3", $d3

charmap "4", $d4
charmap "5", $d5
charmap "6", $d6
charmap "7", $d7

charmap "8", $d8
charmap "9", $d9
charmap "a", $da
charmap "b", $db

charmap "c", $dc
charmap "d", $dd
charmap "e", $de
charmap "f", $df

charmap "g", $e0
charmap "h", $e1
charmap "i", $e2
charmap "j", $e3

charmap "k", $e4
charmap "l", $e5
charmap "m", $e6
charmap "n", $e7

charmap "o", $e8
charmap "p", $e9
charmap "q", $ea
charmap "r", $eb

charmap "s", $ec
charmap "t", $ed
charmap "u", $ee
charmap "v", $ef

charmap "w", $f0
charmap "x", $f1
charmap "y", $f2
charmap "z", $f3

charmap " ", $f4
charmap "!", $f5
charmap "'", $f6
charmap ".", $f7

charmap ",", $f8
charmap ":", $f9
charmap "?", $fa
charmap "$", $fb

endc ; if !def(CHARMAP_INC)
