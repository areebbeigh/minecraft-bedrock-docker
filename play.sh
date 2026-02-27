#!/usr/bin/env bash
set -euo pipefail

PORT1=${1:-19132}
PORT2=${2:-19133}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Name of the Docker image
IMAGE_NAME="bedrock"

# Named volume to persist server state (worlds, templates, treatments, etc.)
STATE_VOLUME="bedrock_state"

# Ensure the named volume exists
if ! docker volume inspect "$STATE_VOLUME" >/dev/null 2>&1; then
  docker volume create "$STATE_VOLUME" \
  --driver local \
  --opt type=none \
  --opt o=bind \
  --opt device="${SCRIPT_DIR}/state" >/dev/null
fi

# Run the Bedrock server container
exec docker run --rm -it \
  --platform=linux/amd64 \
  -p "${PORT1}":19132/udp \
  -p "${PORT2}":19133/udp \
  -v "${STATE_VOLUME}:/data" \
  -v "${SCRIPT_DIR}/server.properties:/data/config/server.properties" \
  -v "${SCRIPT_DIR}/allowlist.json:/data/config/allowlist.json" \
  -v "${SCRIPT_DIR}/permissions.json:/data/config/permissions.json" \
  -v "${SCRIPT_DIR}/packetlimitconfig.json:/data/config/packetlimitconfig.json" \
  "${IMAGE_NAME}"

