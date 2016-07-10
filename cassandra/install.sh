#!/bin/sh
set -eu

echo "*** Installing Cassandra"
curl -SL http://downloads.datastax.com/community/dsc-cassandra-$CASSANDRA_VERSION-bin.tar.gz | tar xz
mv dsc-cassandra-$CASSANDRA_VERSION/* /cassandra/

echo "*** Installing Python"
apk add --update --no-cache python

# Add patch files needed to work around python incompatibility
rm /cassandra/lib/cassandra-driver-internal-only-*
cp -r /cassandra/CASSANDRA-11850/* /cassandra/

# TODO: Add native snappy lib. Native loader stacktraces in the cassandra log as a results, which is distracting.

echo "*** Starting Cassandra"
/cassandra/bin/cassandra

timeout=300
while [[ "$timeout" -gt 0 ]] && ! /cassandra/bin/cqlsh -e 'SHOW VERSION' localhost >/dev/null 2>/dev/null; do
    echo "Waiting ${timeout} seconds for cassandra to come up"
    sleep 10
    timeout=$(($timeout - 10))
done

echo "*** Importing Scheme"
curl https://raw.githubusercontent.com/openzipkin/zipkin/$ZIPKIN_VERSION/zipkin-storage/cassandra/src/main/resources/cassandra-schema-cql3.txt \
     | /cassandra/bin/cqlsh --debug localhost

echo "*** Stopping Cassandra"
pkill -f java

echo "*** Cleaning Up"
apk del python --purge
rm -rf /cassandra/javadoc/ /cassandra/pylib/ /cassandra/tools/ /cassandra/lib/*.zip

echo "*** Image build complete"
