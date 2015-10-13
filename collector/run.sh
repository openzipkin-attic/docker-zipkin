#!/bin/sh
source .${STORAGE_TYPE}_profile

echo "** Starting zipkin collector..."
java -jar zipkin-collector.jar -f /collector-${STORAGE_TYPE}.scala
