This is temporary until we have a means to change yaml at runtime, to set the container IP, etc.

```bash
CASSANDRA_VERSION=2.2.5
curl -L http://downloads.datastax.com/community/dsc-cassandra-$CASSANDRA_VERSION-bin.tar.gz | tar xz
javac -classpath dsc-cassandra-$CASSANDRA_VERSION/lib/apache-cassandra-$CASSANDRA_VERSION.jar ZipkinConfigurationLoader.java
git add  ZipkinConfigurationLoader.class
rm -rf dsc-cassandra-$CASSANDRA_VERSION
```
