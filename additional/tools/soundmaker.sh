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
    convertOne "$1" "../assets-gen/sound/$2" "../assets/sound/$3.mp3"
    convertOne "$1" "../assets-gen/sound/$2" "../assets/sound/$3.ogg"
    convertOne "$1" "../assets-gen/sound/$2" "../assets/sound/$3.wav"
}

cd `dirname "$0"`

# convertMusic 0.25 startBgm.mp3 startBgm
# convertMusic 0.25 gameBgm.mp3 gameBgm
# convertMusic 0.25 flip.mp3 flip
# convertMusic 1 loose.mp3 loose
# convertMusic 1 win.wav win
