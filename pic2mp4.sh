#!/bin/bash

# Script to retrieve images from Hikvision PIC file format and coverting it to mp4 time laps video files.
# Based on https://gist.github.com/Instagraeme/19557ece2db0e1cdb74ec5d8e3bb1618
# wget https://gist.githubusercontent.com/Instagraeme/19557ece2db0e1cdb74ec5d8e3bb1618/raw/cae02e4c11f354b4499859d9b0cc6fe0b32d19ae/decompressPic.py
# pip3 install tqdm
# apt install ffmpeg rename
#

PICDIR=./pic
JPGDIR=./jpg
MP4DIR=./mp4
STARTFILENUM=1

[[ -d $PICDIR ]] || { echo "Source directory does not exist"; exit 0; }
[[ -d $JPGDIR ]] || mkdir -p $JPGDIR
[[ -d $MP4DIR ]] || mkdir -p $MP4DIR

for item in $(ls -la $PICDIR|grep pic |awk '$5 > 0 {print $9}'); do
    python3 decompressPic.py -i $PICDIR/$item -d $JPGDIR/$item/;
done;

for item in $(ls $JPGDIR); do
    cd $JPGDIR/$item;  
    rename 's/Picture-//' *.jpg;
    rename 'unless (/0+[0-9]{4}.jpg/) {s/^([0-9]{1,3}\.jpg)$/000$1/g;s/0*([0-9]{4}\..*)/$1/}' *;
done;

for item in $(ls $JPGDIR); do
    ffmpeg -f image2 -start_number $STARTFILENUM -framerate 24 -i "$JPGDIR/$item/%4d.jpg" -s:v 1920x1080 -c:v libx264 -crf 17 -pix_fmt yuv420p $MP4DIR/$item.mp4;
done;
