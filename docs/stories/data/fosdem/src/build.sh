#!/bin/sh
# Rebuilds the tables of docs/stories/data/fosdem/ from the raw downloads of fetch.sh.
#   sh build.sh <raw dir> <nanuq checkout>
# Step 1 (Nim, standard library only) flattens the raw XML, HTML, YAML history and
# mbox into staging CSVs; step 2 (Nim + nanuq) cleans, joins and aggregates them.
set -eu
RAW=$1
NANUQ=$2
HERE=$(cd "$(dirname "$0")" && pwd)
OUT=$(dirname "$HERE")
STAGE=${STAGE:-$RAW/stage}
mkdir -p "$STAGE/bin"
run() { s=$1; shift; nim c -d:release --hints:off -o:"$STAGE/bin/$s" "$HERE/$s.nim" && "$STAGE/bin/$s" "$@"; }
run extract_xml "$RAW/xml" "$STAGE"
run extract_eventindex "$RAW/pages" "$STAGE"
run extract_devrooms "$RAW/pages" "$STAGE"
run extract_early "$RAW/html" "$STAGE"
run extract_early_devrooms "$RAW/html" "$STAGE"
run extract_trackpages "$RAW/tracks" "$STAGE"
run extract_cfp_yaml "$RAW/fosdem-website" "$STAGE"
run extract_lists "$RAW/lists/fosdem.mbox" "$STAGE"
run extract_stands "$RAW/stands" "$STAGE"
run extract_upcoming "$RAW/upcoming" "$STAGE" "${NEXT:-2027}"
nim c -d:release --hints:off --path:"$NANUQ/src" -o:"$STAGE/bin/process" "$HERE/process.nim"
"$STAGE/bin/process" "$STAGE" "$OUT"
# The small tables of the story (docs/stories/fosdem.nim), from the tables above.
nim c -d:release --hints:off --path:"$NANUQ/src" -o:"$STAGE/bin/insights" "$HERE/insights.nim"
"$STAGE/bin/insights" "$OUT" "$OUT/story"
