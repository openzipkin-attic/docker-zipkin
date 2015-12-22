#!/bin/sh
source .${STORAGE_TYPE}_profile

# the collector is a scribe listener
test "$TRANSPORT_TYPE" != 'scribe' && source .${TRANSPORT_TYPE}_profile

echo "** Starting zipkin collector..."
exec java ${JAVA_OPTS} -jar zipkin-collector.jar -f /collector-${STORAGE_TYPE}.scala
