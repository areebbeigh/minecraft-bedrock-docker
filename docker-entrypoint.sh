#!/usr/bin/env bash
set -euo pipefail

cd /bedrock_server

# Bedrock ships shared libraries in the same directory as the binary.
export LD_LIBRARY_PATH=".:${LD_LIBRARY_PATH:-}"

DATA_DIR="${BEDROCK_DATA_DIR:-/data}"
CONFIG_DIR="${BEDROCK_CONFIG_DIR:-$DATA_DIR/config}"

mkdir -p "$DATA_DIR" "$CONFIG_DIR"

# Persisted state directories (symlinked into /bedrock_server).
state_dirs=(
  "worlds"
  "world_templates"
  "treatments"
)

for d in "${state_dirs[@]}"; do
  mkdir -p "$DATA_DIR/$d"

  # Replace existing directory/file with a symlink to the persisted location.
  if [ -e "/bedrock_server/$d" ] && [ ! -L "/bedrock_server/$d" ]; then
    rm -rf "/bedrock_server/$d"
  fi
  if [ ! -e "/bedrock_server/$d" ]; then
    ln -s "$DATA_DIR/$d" "/bedrock_server/$d"
  fi
done

# Editable config files (stored in $CONFIG_DIR and symlinked into /bedrock_server).
config_files=(
  "server.properties"
  "allowlist.json"
  "permissions.json"
  "packetlimitconfig.json"
)

for f in "${config_files[@]}"; do
  if [ ! -e "$CONFIG_DIR/$f" ] && [ -e "/bedrock_server/$f" ]; then
    cp -a "/bedrock_server/$f" "$CONFIG_DIR/$f"
  fi

  if [ -e "/bedrock_server/$f" ] && [ ! -L "/bedrock_server/$f" ]; then
    rm -f "/bedrock_server/$f"
  fi
  if [ ! -e "/bedrock_server/$f" ] && [ -e "$CONFIG_DIR/$f" ]; then
    ln -s "$CONFIG_DIR/$f" "/bedrock_server/$f"
  fi
done

exec "${@:-./bedrock_server}"

