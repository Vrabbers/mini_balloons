include "music_commands.inc"
include "hardware.inc"

section "Music Engine Variables", wram0
wwSongPC:
        dw

wwChannelsPC:
        dw
        dw
        dw
        dw

wwWaves:
        dw
        dw
        dw
        dw

wCounters:
        db
        db
        db
        db

section "Music Engine", rom0
