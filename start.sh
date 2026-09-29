#!/bin/sh
set -eu

echo "================================="
echo "Starting TShock Server..."
echo "================================="

# Railway persistent volume
DATA_ROOT="${RAILWAY_VOLUME_MOUNT_PATH:-/data}"

# TShock paths
WORLD_DIR="/root/.local/share/Terraria/Worlds"
LOG_DIR="/tshock/logs"
PLUGINS_DIR="/plugins"

# Persistent directories
P_WORLD="${DATA_ROOT}/world"
P_LOGS="${DATA_ROOT}/logs"
P_PLUGINS="${DATA_ROOT}/plugins"

mkdir -p "$P_WORLD"
mkdir -p "$P_LOGS"
mkdir -p "$P_PLUGINS"
mkdir -p "$WORLD_DIR"
mkdir -p "$LOG_DIR"
mkdir -p "$PLUGINS_DIR"

# ---------------------------------
# Create persistent symlinks
# ---------------------------------

link_dir() {
    src="$1"
    dst="$2"

    if [ -L "$src" ]; then
        return 0
    fi

    rm -rf "$src" 2>/dev/null || true
    mkdir -p "$(dirname "$src")"
    ln -s "$dst" "$src"
}

link_dir "$WORLD_DIR" "$P_WORLD"
link_dir "$LOG_DIR" "$P_LOGS"
link_dir "$PLUGINS_DIR" "$P_PLUGINS"

# ---------------------------------
# Default environment variables
# ---------------------------------

: "${WORLD_SIZE:=2}"
: "${WORLD_DIFFICULTY:=2}"
: "${WORLD_FILENAME:=world.wld}"
: "${MAX_PLAYERS:=8}"

WORLD_PATH="${WORLD_DIR}/${WORLD_FILENAME}"

echo "World size: ${WORLD_SIZE}"
echo "World difficulty: ${WORLD_DIFFICULTY}"
echo "World filename: ${WORLD_FILENAME}"
echo "Max players: ${MAX_PLAYERS}"
echo "World path: ${WORLD_PATH}"

# ---------------------------------
# Create world if it doesn't exist
# ---------------------------------

if [ ! -f "$WORLD_PATH" ]; then
    echo "================================="
    echo "World does not exist."
    echo "Creating new world..."
    echo "================================="

    exec /server/TShock.Server \
        -configpath /tshock \
        -logpath /tshock/logs \
        -world "$WORLD_PATH" \
        -autocreate "$WORLD_SIZE" \
        -difficulty "$WORLD_DIFFICULTY" \
        -maxplayers "$MAX_PLAYERS"
else
    echo "================================="
    echo "Existing world found."
    echo "Starting existing world..."
    echo "================================="

    exec /server/TShock.Server \
        -configpath /tshock \
        -logpath /tshock/logs \
        -world "$WORLD_PATH" \
        -maxplayers "$MAX_PLAYERS"
fi