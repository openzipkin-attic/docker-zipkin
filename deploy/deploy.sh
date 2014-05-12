#!/bin/bash
IMG_PREFIX="itszero/zipkin-"
NAME_PREFIX="zipkin-"
PUBLIC_PORT="8080"
ROOT_URL="http://deb.local:$PUBLIC_PORT"

if [[ $CLEANUP == "y" ]]; then
  SERVICES=("cassandra" "collector" "query" "web")
  for i in "${SERVICES[@]}"; do
    echo "** Stopping zipkin-$i"
    docker stop "${NAME_PREFIX}$i"
    docker rm "${NAME_PREFIX}$i"
  done
fi

echo "** Starting zipkin-cassandra"
docker run -d --name="${NAME_PREFIX}cassandra" "${IMG_PREFIX}cassandra"

echo "** Starting zipkin-collector"
docker run -d --link="${NAME_PREFIX}cassandra:db" -p 9410:9410 --name="${NAME_PREFIX}collector" "${IMG_PREFIX}collector"

echo "** Starting zipkin-query"
docker run -d --link="${NAME_PREFIX}cassandra:db" -p 9411:9411 --name="${NAME_PREFIX}query" "${IMG_PREFIX}query"

echo "** Starting zipkin-web"
docker run -d --link="${NAME_PREFIX}query:query" -p 8080:$PUBLIC_PORT -e "ROOTURL=${ROOT_URL}" --name="${NAME_PREFIX}web" "${IMG_PREFIX}web"
