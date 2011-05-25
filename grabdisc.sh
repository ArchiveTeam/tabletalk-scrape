#!/bin/bash
#
# Usage: ./grabdisc.sh DISCUSSION_ID
#
# Downloads all pages of a discussion on tabletalk.salon.com.
# The discussion id is the sequence of letters and numbers in the discussion url
# (excluding the period).
# E.g.: ee9eb07   from   http://tabletalk.salon.com/webx/.ee9eb07
#
# Version 5: Be more persistent: retry until we've got the file.
#            Delete files with a spider warning.
# Version 4: More tries, more timeout for wget. Renamed temp file. Support for proxy.
# Version 3: Better error handling.
# Version 2: Added referer, sleep between requests, stop on error.
# Version 1.
#

DISCUSSION_ID=$1

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"

function selectProxy {
  if [ -f proxies.txt ]
  then
    oIFS=$IFS IFS=$'\n' lines=($(<"proxies.txt")) IFS=$oIFS
    n=${#lines[@]}
    r=$((RANDOM % n))   # see below
    echo "${lines[r]}"
    export http_proxy="${lines[r]}"
  fi
}

DISCUSSION_DIR=data/${DISCUSSION_ID:0:1}/${DISCUSSION_ID:0:2}/${DISCUSSION_ID:0:3}/$DISCUSSION_ID

mkdir -p $DISCUSSION_DIR
touch $DISCUSSION_DIR/.incomplete

echo "Downloading $DISCUSSION_ID: "

INDEX=0
while [ $INDEX -ne -1 ]
do
  echo -n "  $INDEX "

  PAGE="$DISCUSSION_DIR/page.$INDEX.html"
  URL="http://tabletalk.salon.com/webx?14@@.$DISCUSSION_ID/$INDEX"
  TEMPFILE="tmp/tmp-$$.html"

  if [ -f $PAGE ]
  then
    if grep -q "To protect Table Talk from aggressive search spiders" $PAGE
    then
      echo "Removing spider warning."
      rm $PAGE
    fi
  fi

  if [ ! -f $PAGE ]
  then
    # delete temp file
    rm -f $TEMPFILE

    result=99
    while [ ! -f $TEMPFILE ]
    do
      selectProxy

      wget --tries=2 --timeout=30 -U "$USER_AGENT" -nv -O $TEMPFILE "$URL" --referer="http://tabletalk.salon.com/webx/.$DISCUSSION_ID"

      # check for errors
      result=$?
      if [ $result -ne 0 ]
      then
        if [ -f proxies.txt ]
        then
          echo $http_proxy >> badproxies.txt
        fi
        echo "Error!"
        rm -f $TEMPFILE
      fi

      # check for spider warning
      if [ -f $TEMPFILE ]
      then
        if grep -q "To protect Table Talk from aggressive search spiders" $TEMPFILE
        then
	  echo "Spider blocked."
          rm -f $TEMPFILE
        fi
      fi

      if [ ! -f $TEMPFILE ]
      then
        if [ ! -f proxies.txt ]
	then
	  # no proxy change possible; just wait
	  echo "Waiting 10 minutes..."
	  sleep 600
	fi
      fi
    done

    mv $TEMPFILE $PAGE
  
    sleep 1
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

echo "  $DISCUSSION_ID done."

