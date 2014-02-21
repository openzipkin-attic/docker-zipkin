#!/bin/bash
if [[ -z $DB_PORT_7000_TCP_ADDR ]]; then
  echo "** ERROR: You need to link the cassandra container as db."
  exit 1
fi

SERVICE_NAME="zipkin-collector-service"
CONFIG="${SERVICE_NAME}/config/collector-cassandra.scala"

echo "** Starting ${SERVICE_NAME}..."
cd zipkin
sed -i "s/localhost/${DB_PORT_7000_TCP_ADDR}/" $CONFIG
bin/sbt "project $SERVICE_NAME" "run -f $CONFIG"
