This changes the datastax distribution so that it doesn't require access to the `javax.beans` package.

```bash
# compiling a configuration loader which doesn't use snakeyaml
CASSANDRA_VERSION=2.1.9
curl -L http://downloads.datastax.com/community/dsc-cassandra-$CASSANDRA_VERSION-bin.tar.gz | tar xz
javac -classpath dsc-cassandra-$CASSANDRA_VERSION/lib/apache-cassandra-$CASSANDRA_VERSION.jar ZipkinConfigurationLoader.java
git add  ZipkinConfigurationLoader.class
rm -rf dsc-cassandra-$CASSANDRA_VERSION
```
