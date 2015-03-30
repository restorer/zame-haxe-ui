#!/bin/bash

function convertOne {
    if [ "$1" != "1" ] ; then
        sox -v "$1" "$2" -r 22050 "$3" silence 1 0.1 0.1% reverse silence 1 0.1 0.1% reverse
    else
        sox "$2" -r 22050 "$3" silence 1 0.1 0.1% reverse silence 1 0.1 0.1% reverse
    fi
}

function convertMusic {
    echo "$2 ..."
    convertOne "$1" "sound-original/$2" "../assets/sound/$3.mp3"
    convertOne "$1" "sound-original/$2" "../assets/sound/$3.ogg"
    convertOne "$1" "sound-original/$2" "../assets/sound/$3.wav"
}

cd `dirname "$0"`

# convertMusic 1 gameBgm.wav gameBgm
# convertMusic 1 lock.wav lock
# convertMusic 1 loose.wav loose
# convertMusic 1 move.wav move
# convertMusic 1 press.wav press
# convertMusic 1 startBgm.wav startBgm
# convertMusic 1 win.wav win
# convertMusic 1 wrong.wav wrong
