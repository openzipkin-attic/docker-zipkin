#!/bin/sh
source .${STORAGE_TYPE}_profile

if [ "$COLLECTOR_PORT_9410_TCP_ADDR" ]; then
  export SCRIBE_HOST=$COLLECTOR_PORT_9410_TCP_ADDR
  export SCRIBE_PORT=9410
fi

echo "** Starting zipkin query..."
java -jar zipkin-query.jar -f /query-${STORAGE_TYPE}.scala
