# Minecraft Bedrock Docker

Docker setup for running the official Minecraft Bedrock dedicated server. The image is built for **linux/amd64** (required for the Bedrock binary), so on Apple Silicon it runs via emulation.

## Requirements

- [Docker](https://docs.docker.com/get-docker/)
- On Apple Silicon: build/run with `--platform=linux/amd64` (handled by the scripts below)

## Setup: download the Bedrock server

The repo does **not** include the Minecraft Bedrock server binary or its data files. You need to add them once:

1. Open the official download page:  
   **https://www.minecraft.net/en-us/download/server/bedrock**
2. Extract the zip **into this repo directory** (the same folder as `Dockerfile` and `play.sh`). All contents of the zip should end up in the repo root.

Example after extraction:

```
root/          # repo root
├── Dockerfile
├── docker-entrypoint.sh
├── play.sh
├── build.sh
├── README.md
├── .dockerignore
├── .gitignore
├── bedrock_server               # from zip (binary)
├── server.properties            # from zip (edit for your server)
├── allowlist.json
├── permissions.json
├── packetlimitconfig.json
├── release-notes.txt
├── bedrock_server_how_to.html
├── behavior_packs/
├── config/
├── definitions/
├── resource_packs/
├── world_templates/              # empty or defaults from zip
└── state/                       # created on first run by play.sh
    ├── worlds/
    ├── world_templates/
    └── treatments/
```

Then build and run (see **Commands** below).

## Project layout

| Path | Purpose |
|------|--------|
| `Dockerfile` | Ubuntu 24.04 image, runtime libs, entrypoint |
| `docker-entrypoint.sh` | Sets `LD_LIBRARY_PATH`, symlinks state + config from `/data` |
| `play.sh` | Script to run the server with correct volumes and ports |
| `state/` | Persisted server state (worlds, templates, treatments); created by `play.sh` |
| `server.properties`, `allowlist.json`, `permissions.json`, `packetlimitconfig.json` | Config files; bind-mounted so you can edit without rebuilding |

State and config are kept **outside** the image: worlds and editable configs live in a **state volume** (bind-mounted to `./state`) and in the repo, so you can change settings and restart without rebuilding.

## Commands

### Build the image

```bash
docker build --platform=linux/amd64 -t bedrock .
```

### Run the server

```bash
chmod +x play.sh
./play.sh
```

By default `play.sh` publishes UDP **19132** and **19133**. To use different host ports:

```bash
./play.sh 19132 19133   # same as default
./play.sh 25566 25567   # example: host 25566→19132, 25567→19133
```

### Connect from other devices (LAN)

The container publishes on `0.0.0.0`, so other devices on your Wi‑Fi can connect using:

- **Server address:** your Mac’s local IP (e.g. `192.168.1.5`)
- **Port:** `19132` (or the first port you passed to `play.sh`)

Find your IP: `ipconfig getifaddr en0` (Wi‑Fi) or check System Settings → Network.

Remote access also can be setup with [Tailscale](https://tailscale.com/).

### Edit config without rebuilding

Edit these in the project directory (they are bind-mounted into the container):

- `server.properties`
- `allowlist.json`
- `permissions.json`
- `packetlimitconfig.json`

Restart the container for changes to apply (`Ctrl+C` then `./play.sh` again).

## How it works

1. **Image:** Ubuntu 24.04 (amd64) with libcurl, OpenSSL, and C++ runtime. The Bedrock server binary and its `.so` files are copied into `/bedrock_server`. `LD_LIBRARY_PATH=.` is set so the binary finds its libraries.

2. **Entrypoint:** On start, `docker-entrypoint.sh`:
   - Sets `LD_LIBRARY_PATH` and uses `/data` (and `/data/config`) for persisted state and config.
   - Creates symlinks so `/bedrock_server/worlds`, `world_templates`, and `treatments` point into `/data`, and the four config files point into `/data/config`.
   - Runs `./bedrock_server` (or the container `CMD`).

3. **play.sh:** Creates a Docker volume that is **bind-mounted** to `./state` on the host, and mounts that volume at `/data`. It also bind-mounts the four config files from the repo into `/data/config/`. Ports 19132 and 19133 are published so the server is reachable on the host (and thus on your LAN).

---

## Todo

- [ ] Auto download Minecraft server distribution on setup.
- [ ] Make running multiple servers easier.
