#!/bin/bash
a="`curl checkip.dyndns.org | sed -e 's/.*: //' -e 's/<.*$//'`"
/usr/local/bin/convert -size 420x95 xc:transparent -font /Library/Fonts/Arial.ttf -gravity Center -fill "#e0e0e0" -pointsize 56 -draw "text 0,0 '$a'" -rotate -90 ~/image.png
echo `date '+%A %x'`
