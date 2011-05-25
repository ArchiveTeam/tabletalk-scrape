#!/bin/bash
#
# Usage: ./dld-all.sh FILENAME
#
# Downloads the discussions from a list of discussion ids.
#

IDS=`cat $1`
ERRORS=0

for id in $IDS
do
  if [ ! -f STOP ]
  then
    ./grabdisc.sh $id
    if [ $? -ne 0 ]
    then
      echo "Error! Rerun."
      ERRORS=1
    fi
  fi
done

if [ $ERRORS -ne 0 ]
then
  echo "There were some errors. Rerun the script to download missing files."
fi

