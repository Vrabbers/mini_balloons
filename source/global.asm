
section "Global WRAM variables", wram0
wFrameCounter:: db

wwMainCallback:: dw
wMainDone:: db
wwVBlankCallback:: dw

wWasVBlankInt:: db

section "Global HRAM Variables", hram
hScratch:: ds 1
hJoypad:: db
hJoypadPressed:: db
