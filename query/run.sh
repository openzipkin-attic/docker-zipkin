#!/bin/sh
source .${STORAGE_TYPE}_profile
test -n "$TRANSPORT_TYPE" && source .${TRANSPORT_TYPE}_profile

echo "** Starting zipkin query..."
exec java -jar zipkin-query.jar -f /query-${STORAGE_TYPE}.scala
