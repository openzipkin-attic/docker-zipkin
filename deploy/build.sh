#!/bin/bash

# http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

PREFIX="itszero/zipkin-"
IMAGES=("base" "cassandra" "collector" "query" "web")

for image in ${IMAGES[@]}; do
  pushd "../$image"
  docker build -t "$PREFIX$image" .
  popd
done
