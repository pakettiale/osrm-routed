#!/bin/sh
# Regenerate data/ from fresh Geofabrik extracts
set -eu
cd "$(dirname "$0")"

mkdir -p build
for r in finland sweden norway; do
    curl -fL -o build/$r.osm.pbf https://download.geofabrik.de/europe/$r-latest.osm.pbf
done

docker run --rm -v "$PWD:/w" -w /w --entrypoint sh ghcr.io/project-osrm/osrm-backend:v5.27.1 -c "
    apt-get update -q && apt-get install -yq osmium-tool
    rm -rf data && mkdir data
    osmium merge build/*.osm.pbf -o data/data.osm.pbf
    osrm-extract -p /opt/car.lua data/data.osm.pbf
    osrm-partition data/data.osrm
    osrm-customize data/data.osrm
    rm data/data.osm.pbf
    chown -R $(id -u):$(id -g) data"

date +%F > data/VERSION
