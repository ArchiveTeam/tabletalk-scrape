#!/bin/bash
#
# Usage: ./grabdisc.sh DISCUSSION_ID
#
# Downloads all pages of a discussion on tabletalk.salon.com.
# The discussion id is the sequence of letters and numbers in the discussion url
# (excluding the period).
# E.g.: ee9eb07   from   http://tabletalk.salon.com/webx/.ee9eb07
#
# Version 3: Better error handling.
# Version 2: Added referer, sleep between requests, stop on error.
# Version 1.
#

DISCUSSION_ID=$1

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"

DISCUSSION_DIR=data/${DISCUSSION_ID:0:1}/${DISCUSSION_ID:0:2}/${DISCUSSION_ID:0:3}/$DISCUSSION_ID

mkdir -p $DISCUSSION_DIR
touch $DISCUSSION_DIR/.incomplete

echo -n "Downloading $DISCUSSION_ID: "

INDEX=0
while [ $INDEX -ne -1 ]
do
  echo -n "$INDEX "

  PAGE="$DISCUSSION_DIR/page.$INDEX.html"
  URL="http://tabletalk.salon.com/webx?14@@.$DISCUSSION_ID/$INDEX"
  # wget -nv -a wget.log -U "$USER_AGENT" --no-clobber -O $PAGE "$URL"
  if [ ! -f $PAGE ]
  then
    wget -U "$USER_AGENT" -O tmp.html "$URL" --referer="http://tabletalk.salon.com/webx/.$DISCUSSION_ID"

    result=$?
    if [ $result -ne 0 ]
    then
      echo $result
      echo "Error!"
      exit 1
    fi

    mv tmp.html $PAGE
  
    sleep 2
  fi

  if grep -q -E "LAST</a>" $PAGE
  then
    # 50 messages per page
    INDEX=$((INDEX + 50))
  else
    INDEX=-1
  fi
done

rm $DISCUSSION_DIR/.incomplete

echo "done."

