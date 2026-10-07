#!/bin/sh
set -eu

DATA_DIR="${OSRM_DATA_DIR:-/opt/osrm/data}"
mkdir -p "$DATA_DIR"

# A bind mount hides the files bundled in the image. Seed an empty mount while
# leaving any precalculated files copied to this machine untouched.
#
# osrm-extract/partition/customize (without --dump-nbg-graph) never produce a
# literal "data.osrm" file, only "data.osrm.*" siblings, so that name can't be
# used as a completion marker. Use data.osrm.mldgr instead: it's written last
# by osrm-customize, so its absence also means an interrupted init is retried.
if [ ! -f "$DATA_DIR/data.osrm.mldgr" ]; then
    echo "Initializing OSRM data in $DATA_DIR"
    rm -f "$DATA_DIR"/data.osrm*
    for f in /opt/osrm/precalculated/data.osrm.*; do
        [ "$(basename "$f")" = "data.osrm.mldgr" ] && continue
        cp -a "$f" "$DATA_DIR"/
    done
    # Copy the completion marker last so an interrupted initialization is retried.
    cp -a /opt/osrm/precalculated/data.osrm.mldgr "$DATA_DIR"/
fi

# OSRM_ARGS: extra osrm-routed flags, e.g. --mmap=true to avoid loading the graph into RAM
# shellcheck disable=SC2086
exec osrm-routed --port 8080 --algorithm mld ${OSRM_ARGS:-} "$DATA_DIR/data.osrm"
