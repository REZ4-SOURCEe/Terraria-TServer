#!/bin/sh
set -eu

DATA_ROOT="${RAILWAY_VOLUME_MOUNT_PATH:-/data}"

WORLD_DIR="/root/.local/share/Terraria/Worlds"
LOG_DIR="/tshock/logs"
PLUGINS_DIR="/plugins"

P_WORLD="${DATA_ROOT}/world"
P_LOGS="${DATA_ROOT}/logs"
P_PLUGINS="${DATA_ROOT}/plugins"

mkdir -p "$P_WORLD" "$P_LOGS" "$P_PLUGINS"

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

if [ -z "${WORLD_FILENAME:-}" ]; then
  first_wld="$(ls -1 "${WORLD_DIR}"/*.wld 2>/dev/null | head -n 1 || true)"

  if [ -n "$first_wld" ]; then
    WORLD_FILENAME="$(basename "$first_wld")"
    export WORLD_FILENAME
  else
    WORLD_FILENAME="world.wld"
    export WORLD_FILENAME
  fi
fi

: "${WORLD_SIZE:=2}"
: "${WORLD_DIFFICULTY:=2}"

ARGS=""

if [ ! -f "${WORLD_DIR}/${WORLD_FILENAME}" ]; then
  echo "Creating new world with size ${WORLD_SIZE} and difficulty ${WORLD_DIFFICULTY}..."
  ARGS="$ARGS -autocreate ${WORLD_SIZE} -difficulty ${WORLD_DIFFICULTY}"
fi

echo "Starting TShock..."

exec /server/TShock.Server \
  -configpath /tshock \
  -logpath /tshock/logs \
  -worldselectpath /root/.local/share/Terraria/Worlds \
  -additionalplugins /plugins \
  $ARGS