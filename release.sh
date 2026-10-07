#!/bin/sh
# Build and push :latest and :<version> (default data/VERSION) to GHCR
set -eu
cd "$(dirname "$0")"

IMAGE=ghcr.io/pakettiale/osrm-routed
VERSION=${1:-$(cat data/VERSION)}

docker build -t $IMAGE:latest -t $IMAGE:$VERSION .
docker push $IMAGE:latest
docker push $IMAGE:$VERSION
