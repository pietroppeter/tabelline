#!/bin/sh
# Downloads the raw FOSDEM sources into $1 (default: ./raw). Nothing here is committed:
# the raw files are ~200 MB. Hosts needed: archive.fosdem.org, fosdem.org, lists.fosdem.org, github.com.
set -eu
RAW=${1:-raw}
mkdir -p "$RAW/xml" "$RAW/html" "$RAW/pages/devrooms" "$RAW/tracks" "$RAW/lists"
A=https://archive.fosdem.org

# 2012-2026: the schedule XML of each edition (Pentabarf, pretalx from 2026).
for y in $(seq 2012 2026); do curl -sSf -o "$RAW/xml/$y.xml" "$A/$y/schedule/xml"; done

# 2001-2006: the old sites, as they are archived (no schedule export then).
for y in $(seq 2001 2006); do
  (cd "$RAW/html" && wget -q -r -l 4 -np -nH -e robots=off --wait=0.2 -T 20 \
    --reject 'jpg,jpeg,png,gif,pdf,css,js,ico,ogg,ogv,avi,mp4,webm,zip,tgz,svg,odp,ppt,pptx,mp3,flv' \
    "$A/$y/") || true   # wget exits non-zero on the archive's broken links
done

# 2007-2011: event index and speakers pages; 2007-2010 also the devroom index and pages.
for y in $(seq 2007 2011); do
  curl -sSf -o "$RAW/pages/events$y.html" "$A/$y/schedule/events.html"
  curl -sSf -o "$RAW/pages/speakers$y.html" "$A/$y/schedule/speakers.html"
done
for y in $(seq 2007 2010); do
  curl -sSf -o "$RAW/pages/devrooms$y.html" "$A/$y/schedule/devrooms.html"
  dir=devrooms; [ "$y" -le 2008 ] && dir=devroom
  for d in $(grep -o "href=\"$dir/[^\"]*\.html\"" "$RAW/pages/devrooms$y.html" | sed "s|href=\"$dir/||;s|\"||" | sort -u); do
    curl -sSf -o "$RAW/pages/devrooms/$y-$d" "$A/$y/schedule/$dir/$d"
  done
  curl -sSf -o "$RAW/pages/devrooms/$y-lightningtalks.html" "$A/$y/schedule/tracks/lightningtalks.html"
done

# 2013-2026: every track page (CfP link, rooms, group).
for y in $(seq 2013 2026); do
  mkdir -p "$RAW/tracks/$y"
  curl -sSf -o "$RAW/tracks/$y/index.html" "$A/$y/schedule/tracks/"
  for t in $(grep -o "href=\"/$y/schedule/track/[^\"]*/\"" "$RAW/tracks/$y/index.html" | sed "s|href=\"/$y/schedule/track/||;s|/\"||" | sort -u); do
    curl -sSf -o "$RAW/tracks/$y/$t.html" "$A/$y/schedule/track/$t/"
  done
done

# The fosdem@lists.fosdem.org archive (2006-), as one mbox.
curl -sSf -o "$RAW/lists/fosdem.mbox.gz" \
  "https://lists.fosdem.org/hyperkitty/list/fosdem@lists.fosdem.org/export/fosdem.mbox.gz?start=2000-01-01&end=2030-12-31"
gunzip -kf "$RAW/lists/fosdem.mbox.gz"

# The next edition, as announced on fosdem.org: dates and accepted devrooms.
NEXT=${NEXT:-2027}
mkdir -p "$RAW/upcoming"
curl -sSf -o "$RAW/upcoming/accepted-developer-rooms.html" "https://fosdem.org/$NEXT/news/accepted-developer-rooms/"
curl -sSf -o "$RAW/upcoming/fosdem-$NEXT-dates.html" "https://fosdem.org/$NEXT/news/fosdem-$NEXT-dates/"

# FOSDEM's archived website (2013-2025), for the history of devrooms-cfp.yaml.
[ -d "$RAW/fosdem-website" ] || git clone -q --filter=blob:none https://github.com/FOSDEM/website "$RAW/fosdem-website"
