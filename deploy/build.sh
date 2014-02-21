#!/bin/bash
PREFIX="itszero/zipkin-"
IMAGES=("base" "cassandra" "collector" "query" "web")

for image in ${IMAGES[@]}; do
  pushd "../$image"
  docker build -t "$PREFIX$image" .
  popd
done
