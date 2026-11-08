#!/bin/sh
# Rebuilds the tables of docs/stories/data/fosdem/ from the raw downloads of fetch.sh.
#   sh build.sh <raw dir> <nanuq checkout>
# Step 1 (Python, standard library only) flattens the raw XML, HTML, YAML history and
# mbox into staging CSVs; step 2 (Nim + nanuq) cleans, joins and aggregates them.
set -eu
RAW=$1
NANUQ=$2
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(dirname "$HERE")
STAGE=${STAGE:-$RAW/stage}
mkdir -p "$STAGE"
py() { python3 -I "$HERE/$1" "$2" "$STAGE"; }
py extract_xml.py "$RAW/xml"
py extract_eventindex.py "$RAW/pages"
py extract_devrooms.py "$RAW/pages"
py extract_early.py "$RAW/html"
py extract_early_devrooms.py "$RAW/html"
py extract_trackpages.py "$RAW/tracks"
py extract_cfp_yaml.py "$RAW/fosdem-website"
py extract_lists.py "$RAW/lists/fosdem.mbox"
python3 -I "$HERE/extract_upcoming.py" "$RAW/upcoming" "$STAGE" "${NEXT:-2027}"
nim c -d:release --hints:off --path:"$NANUQ/src" -o:"$STAGE/process" "$HERE/process.nim"
"$STAGE/process" "$STAGE" "$OUT"
# The small tables of the story (docs/stories/fosdem.nim), from the tables above.
nim c -d:release --hints:off --path:"$NANUQ/src" -o:"$STAGE/insights" "$HERE/insights.nim"
"$STAGE/insights" "$OUT" "$OUT/story"
