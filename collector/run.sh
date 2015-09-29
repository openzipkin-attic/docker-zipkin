#!/bin/sh
if [[ -z $CASSANDRA_CONTACT_POINTS ]]; then
  if [[ -z $DB_PORT_9042_TCP_ADDR ]]; then	
  	echo "** ERROR: You need to link container with Cassandra container or specify CASSANDRA_CONTACT_POINTS env var."
  	echo "DB_PORT_9042_TCP_ADDR (container link) or CASSANDRA_CONTACT_POINTS should contain a comma separated list of Cassandra contact points"
  	exit 1
  fi
  CASSANDRA_CONTACT_POINTS=$DB_PORT_9042_TCP_ADDR
fi

export CASSANDRA_CONTACT_POINTS
echo "Cassandra contact points: $CASSANDRA_CONTACT_POINTS"

echo "** Starting zipkin collector..."
java -jar zipkin-collector.jar -f /collector-cassandra.scala
