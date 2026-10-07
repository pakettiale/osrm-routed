FROM ghcr.io/project-osrm/osrm-backend:v5.27.1 AS builder

WORKDIR /opt/osrm

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl osmium-tool \
    && rm -rf /var/lib/apt/lists/*

RUN curl --fail --location --retry 3 --output finland.osm.pbf \
        https://download.geofabrik.de/europe/finland-latest.osm.pbf \
    && curl --fail --location --retry 3 --output sweden.osm.pbf \
        https://download.geofabrik.de/europe/sweden-latest.osm.pbf \
    && curl --fail --location --retry 3 --output norway.osm.pbf \
        https://download.geofabrik.de/europe/norway-latest.osm.pbf \
    && osmium merge finland.osm.pbf sweden.osm.pbf norway.osm.pbf \
        --output data.osm.pbf \
    && rm finland.osm.pbf sweden.osm.pbf norway.osm.pbf

RUN osrm-extract -p /opt/car.lua data.osm.pbf \
    && osrm-partition data.osrm \
    && osrm-customize data.osrm \
    && rm data.osm.pbf

FROM ghcr.io/project-osrm/osrm-backend:v5.27.1

WORKDIR /opt/osrm
COPY --from=builder /opt/osrm/data.osrm* /opt/osrm/precalculated/
COPY start-osrm.sh /usr/local/bin/start-osrm

EXPOSE 8080
CMD ["/bin/sh", "/usr/local/bin/start-osrm"]
