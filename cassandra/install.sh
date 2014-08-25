echo "*** Adding Cassandra deb source"
cat << EOF >> /etc/apt/sources.list
deb http://www.apache.org/dist/cassandra/debian 11x main
deb-src http://www.apache.org/dist/cassandra/debian 11x main
EOF

echo "*** Importing Cassandra deb keys"
gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D
gpg --export --armor F758CE318D77295D | apt-key add -

gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00
gpg --export --armor 2B5C1B00 | apt-key add -

echo "*** Installing Cassandra"
apt-get update
apt-get install -y cassandra procps wget

echo "*** Starting Cassandra"
sed -i s/Xss180k/Xss256k/ /etc/cassandra/cassandra-env.sh
/usr/sbin/cassandra
sleep 5

echo "*** Importing Scheme"
wget https://raw2.github.com/twitter/zipkin/master/zipkin-cassandra/src/schema/cassandra-schema.txt
cassandra-cli -host localhost -port 9160 -f cassandra-schema.txt

echo "*** Stopping Cassandra"
killall java

mv /etc/cassandra/cassandra.yaml /etc/cassandra/cassandra.default.yaml

echo "*** Image build complete"
