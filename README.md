# osrm-routed

[OSRM](https://github.com/Project-OSRM/osrm-backend) v5.27.1 routing server (car profile, MLD) for Finland, Sweden and Norway, with the precalculated routing graph baked into the image.

```
ghcr.io/pakettiale/osrm-routed:latest
ghcr.io/pakettiale/osrm-routed:2026-08-17   # tag = date of the OSM data
```
## Run

```sh
docker run -p 8080:8080 \
  -e OSRM_DATA_DIR=/opt/osrm/precalculated \
  -e OSRM_ARGS=--mmap=true \
  ghcr.io/pakettiale/osrm-routed:latest

curl 'http://localhost:8080/route/v1/driving/24.9384,60.1699;23.7610,61.4978?overview=false'
```

| Variable | Default | |
|---|---|---|
| `OSRM_DATA_DIR` | `/opt/osrm/data` | Directory osrm-routed reads `data.osrm.*` from. If it has no `data.osrm.mldgr`, the bundled files are copied there first (~4.5 GB). Point it at `/opt/osrm/precalculated` to use the bundled files directly, or mount a volume at the default path to keep the copy between restarts. |
| `OSRM_ARGS` | | Extra `osrm-routed` flags, e.g. `--mmap=true`. |

The HTTP API listens on port 8080; see the [OSRM API docs](https://project-osrm.org/docs/v5.24.0/api/).

### Memory: `--mmap=true` or not

- **Without `--mmap`**, the whole graph is loaded into RAM at startup: ~4–5 GB per container, and no first-query latency.
- **With `--mmap=true`**, startup is instant and the process itself uses ~200 MB. Map data is paged in from disk as queries touch it, so the first query in a region takes up to ~0.9 s. Later queries take 6–12 ms.

  Pages that have been read stay in the page cache and count toward the container's cgroup memory: about 1.7 GB after a varied benchmark. This cache is reclaimable. To bound it, set a memory limit (e.g. `--memory 1g`); the kernel then evicts map pages instead of OOM-killing.

Measured locally with mmap (16 threads): about 1,300 req/s at 16 or more concurrent requests, p50 12 ms. A warm 16×16 `table` call takes about 33 ms, and `nearest` takes about 3 ms.

## Build and publish

`data/` (gitignored, ~4.5 GB) holds the precalculated graph.

```sh
./rebuild.sh            # regenerate data/ from fresh Geofabrik extracts
./release.sh [version]  # push :latest and :<version> (default data/VERSION) to GHCR
```

## Data

Map data © [OpenStreetMap contributors](https://www.openstreetmap.org/copyright), available under the [Open Database License (ODbL)](https://opendatacommons.org/licenses/odbl/). The routing graph in the image is derived from the [Geofabrik](https://download.geofabrik.de/) extracts of that data and is distributed under the same license.

## License

The code in this repository is licensed under the [BSD 2-Clause License](LICENSE). The map data is under the ODbL, as described above.
