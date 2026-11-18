#!/bin/sh
set -eu

usage() {
  printf 'Usage: sh %s [html|pdf|pptx]\n' "$0"
}

if [ "$#" -gt 1 ]; then
  usage >&2
  exit 2
fi

format=${1:-html}
case "$format" in
  html|pdf|pptx) ;;
  -h|--help) usage; exit 0 ;;
  *) usage >&2; exit 2 ;;
esac

directory=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
output="$directory/build"
# Pin the multi-platform image, including its bundled browser and dependencies.
image='marpteam/marp-cli:v4.5.1@sha256:3cf660df7b9737f875e57f7169dff0b08d1d3ab604ea2d655ab761102942fa42'

mkdir -p "$output"

docker run --rm --init \
  --network none \
  --read-only \
  --cap-drop ALL \
  --security-opt no-new-privileges=true \
  --user "$(id -u):$(id -g)" \
  --env HOME=/tmp \
  --tmpfs /tmp:rw,nosuid,nodev,size=512m \
  --shm-size=256m \
  --mount "type=bind,source=$directory,target=/slides,readonly" \
  --mount "type=bind,source=$output,target=/output" \
  --workdir /slides \
  --entrypoint marp-cli.js \
  "$image" \
  --no-config-file --allow-local-files \
  /slides/slides.md --output "/output/slides.$format"

if [ "$format" = html ] && [ -d "$directory/assets" ]; then
  mkdir -p "$output/assets"
  cp -R "$directory/assets/." "$output/assets/"
fi

printf 'Created %s/slides.%s\n' "$output" "$format"
