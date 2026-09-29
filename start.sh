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

if [ ! -f "${WORLD_DIR}/config.json" ]; then
  printf '%s\n' '{}' > "${WORLD_DIR}/config.json"
fi

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

if [ ! -f "${WORLD_DIR}/${WORLD_FILENAME}" ]; then
  echo "Creating new world with size ${WORLD_SIZE} and difficulty ${WORLD_DIFFICULTY}..."
  set -- "$@" -autocreate "${WORLD_SIZE}" -difficulty "${WORLD_DIFFICULTY}"
fi

SANITIZED_ARGS=""
skip_next=0

for a in "$@"; do
  if [ "$skip_next" -eq 1 ]; then
    skip_next=0
    continue
  fi

  case "$a" in
    -world|-configpath|-logpath)
      skip_next=1
      continue
      ;;
    *)
      SANITIZED_ARGS="${SANITIZED_ARGS} $(printf "%s" "$a")"
      ;;
  esac
done

echo "Final args: $SANITIZED_ARGS"

cd /tshock

exec dotnet TerrariaServer.dll $SANITIZED_ARGS