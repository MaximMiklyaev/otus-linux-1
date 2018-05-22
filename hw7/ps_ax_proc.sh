#!/bin/bash

for i in $(ls -d /proc/[0-9]* | sort -V);
  do
     if [ -f "$i/cmdline" ] && [ "`cat $i/cmdline | awk 'END { print (NR > 0 && NF > 0) ? "1" : "0"}'`" == "1" ]
     then
       echo -ne "$(basename $i)\t" \
       && cat $i/stat | awk  '{ printf $3 "\t"}' \
       && cat $i/cmdline | awk -F/ '{ if(match($NF,/[a-z]+/)) printf $NF; }' && echo;
     fi
done

