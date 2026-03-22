#!/bin/bash

PACK_LOCATION=$1
WORLD_NAME=$2
WORLD_LOCATION="$(pwd)/state/worlds/$WORLD_NAME"
PACK_NAME="${PACK_LOCATION%/}"
PACK_NAME="${PACK_NAME##*/}"

if [ ! -d "$WORLD_LOCATION" ]; then
    echo "World $WORLD_NAME not found"
    exit 1
fi

if [ ! -d "$PACK_LOCATION" ]; then
    echo "Pack $PACK_LOCATION not found"
    exit 1
fi

PACK_ID=$(cat "$PACK_LOCATION/manifest.json" | jq -r ".header.uuid")
echo "Pack ID: $PACK_ID"
PACK_ENTRY_JSON="{
    "pack_id" : "\"$PACK_ID\"",
    "version" : [ 1, 0, 0 ]
}
"

mkdir -p "$WORLD_LOCATION/behavior_packs"
rm -r "$WORLD_LOCATION/behavior_packs/$PACK_NAME"
cp -r "$PACK_LOCATION" "$WORLD_LOCATION/behavior_packs/$PACK_NAME"

if [ ! -f "$WORLD_LOCATION/world_behavior_packs.json" ]; then
    echo "[]" > "$WORLD_LOCATION/world_behavior_packs.json"
fi

if ! grep -q "$PACK_ID" "$WORLD_LOCATION/world_behavior_packs.json"; then
    echo "Adding pack $PACK_ID to world $WORLD_NAME"
    jq ". += [$PACK_ENTRY_JSON]" "$WORLD_LOCATION/world_behavior_packs.json" > "$WORLD_LOCATION/world_behavior_packs.json.tmp"
    mv "$WORLD_LOCATION/world_behavior_packs.json.tmp" "$WORLD_LOCATION/world_behavior_packs.json"
else
    echo "Pack $PACK_ID already in world $WORLD_NAME"
fi
