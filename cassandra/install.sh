#!/bin/bash

set -eu

echo "*** Adding Cassandra deb source"
cat << EOF >> /etc/apt/sources.list
deb http://www.apache.org/dist/cassandra/debian 21x main
deb-src http://www.apache.org/dist/cassandra/debian 21x main
EOF

echo "*** Importing Cassandra deb keys"
gpg --keyserver keys.gnupg.net --recv-keys 749D6EEC0353B12C
gpg --export --armor 749D6EEC0353B12C | apt-key add -

echo "*** Installing Cassandra"
apt-get update
# adduser, python and python-support are dependencies of cassandra
# we'll install cassandra without dependency checks to use the JRE 8 provided by the base image
# otherwise it'd pull in JRE 7
apt-get install -y procps wget adduser python>=2.7 python-support>=0.90.0
apt-get download cassandra
dpkg --force-depends -i cassandra*.deb
rm cassandra*.deb

echo "*** Starting Cassandra"
sed -i s/Xss180k/Xss256k/ /etc/cassandra/cassandra-env.sh
/usr/sbin/cassandra

timeout=300
while [[ "$timeout" -gt 0 ]] && ! cqlsh -e 'SHOW VERSION' localhost >/dev/null 2>/dev/null; do
    echo "Waiting ${timeout} seconds for cassandra to come up"
    sleep 10
    timeout=$(($timeout - 10))
done

echo "*** Importing Scheme"
wget https://raw.githubusercontent.com/openzipkin/zipkin/$ZIPKIN_VERSION/zipkin-cassandra-core/src/main/resources/cassandra-schema-cql3.txt
cqlsh --debug -f cassandra-schema-cql3.txt localhost

echo "*** Stopping Cassandra"
pkill -f java

mv /etc/cassandra/cassandra.yaml /etc/cassandra/cassandra.default.yaml

echo "*** Image build complete"
