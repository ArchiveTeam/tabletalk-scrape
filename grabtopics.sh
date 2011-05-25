#!/bin/bash
#
# Downloads the topic and attics pages.
#

USER_AGENT="Googlebot/2.1 (+http://www.googlebot.com/bot.html)"

TOPICS_DIR=data/topics
mkdir -p $TOPICS_DIR

PAGE=$TOPICS_DIR/index.html
URL="http://tabletalk.salon.com/webx/"

wget -U "$USER_AGENT" --no-clobber -O $PAGE "$URL" --referer="http://tabletalk.salon.com/webx/"
TOPICS=`grep -E "/webx/[^/]+/\"" $PAGE | grep -o -E "/webx/[^/]+/"`

for topic in $TOPICS
do
  topic=${topic/\/webx\//}
  topic=${topic/\//}

  echo $topic
  PAGE=$TOPICS_DIR/topic.$topic.html
  URL="http://tabletalk.salon.com/webx/$topic/"
  if [ ! -f $PAGE ]
  then
    wget -U "$USER_AGENT" --no-clobber -O $PAGE "$URL" --referer="http://tabletalk.salon.com/webx/"
    sleep 10
  fi
done

ATTICS=`grep -h -o -E "/webx/.+Attic/" data/topics/topic.*`

for attic in $ATTICS
do
  attic_name=`basename ${attic%\/}`
  echo $attic

  PAGE=$TOPICS_DIR/attic.$attic_name.html
  URL="http://tabletalk.salon.com$attic"
  if [ ! -f $PAGE ]
  then
    wget -U "$USER_AGENT" --no-clobber -O $PAGE "$URL" --referer="http://tabletalk.salon.com$attic"
    sleep 10
  fi
done

