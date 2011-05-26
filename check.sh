#!/bin/bash
#
# Usage: ./check.sh ID_FILE_1 ID_FILE_2 ...
#
# Checks if all discussions from the given file(s) are complete.
#

for idfile in "$@"
do
  IDS=`cat $idfile`
  ERRORS=0

  for id in $IDS
  do
    discussion_dir=data/${id:0:1}/${id:0:2}/${id:0:3}/$id
    if [[ ! -d $discussion_dir || -f $discussion_dir/.incomplete ]]
    then
      # echo "Missing $id."
      ERRORS=$((ERRORS + 1))
    fi
  done

  if [ $ERRORS -eq 0 ]
  then
    echo "$idfile: complete."
  else
    echo "$idfile: $ERRORS missing or incomplete"
  fi
done

