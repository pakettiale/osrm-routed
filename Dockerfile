FROM ghcr.io/project-osrm/osrm-backend:v5.27.1

LABEL org.opencontainers.image.source=https://github.com/pakettiale/osrm-routed

WORKDIR /opt/osrm
# Precalculated (osrm-extract/partition/customize, MLD) Finland+Sweden+Norway graph
COPY data/data.osrm.* /opt/osrm/precalculated/
COPY start-osrm.sh /usr/local/bin/start-osrm

# Default OSRM_DATA_DIR, writable so start-osrm can seed it without root
RUN mkdir /opt/osrm/data && chown 1000:1000 /opt/osrm/data
USER 1000:1000

EXPOSE 8080
CMD ["/bin/sh", "/usr/local/bin/start-osrm"]
