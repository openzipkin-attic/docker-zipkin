#!/bin/sh
set -eu

echo "*** Installing Cassandra"
curl -SL http://downloads.datastax.com/community/dsc-cassandra-$CASSANDRA_VERSION-bin.tar.gz | tar xz
mv dsc-cassandra-$CASSANDRA_VERSION/* /cassandra/

# Logback and yaml use java.beans package not in the JRE, we are setting configuration manually and using slf4j-simple.
curl -SL https://jcenter.bintray.com/org/slf4j/slf4j-simple/$SLF4J_VERSION/slf4j-simple-$SLF4J_VERSION.jar > /cassandra/lib/slf4j-simple-$SLF4J_VERSION.jar
rm -rf /cassandra/conf /cassandra/lib/snakeyaml* /cassandra/lib/logback*

echo "*** Installing Python"
apk add python

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
curl https://raw.githubusercontent.com/openzipkin/zipkin/$ZIPKIN_VERSION/zipkin-cassandra-core/src/main/resources/cassandra-schema-cql3.txt \
     | /cassandra/bin/cqlsh --debug localhost

echo "*** Stopping Cassandra"
pkill -f java

echo "*** Cleaning Up"
apk del python --purge
rm -rf /cassandra/javadoc/ /cassandra/pylib/ /cassandra/tools/ /cassandra/lib/*.zip

echo "*** Image build complete"
