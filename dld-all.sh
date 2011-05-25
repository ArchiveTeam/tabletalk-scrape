#!/bin/bash
#
# Usage: ./dld-all.sh FILENAME
#
# Downloads the discussions from a list of discussion ids.
#

IDS=`cat $1`

for id in $IDS
do
  if [ ! -f STOP ]
  then
    ./grabdisc.sh $id
    if [ $? -ne 0 ]
    then
      echo "Error!"
      exit
    fi
  fi
done

