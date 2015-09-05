FROM quay.io/openzipkin/zipkin-base:base-1.5.1
MAINTAINER OpenZipkin "http://zipkin.io/"

# Logback and yaml use java.beans package not in the JRE, we are setting configuration manually and using slf4j-simple.
ADD ZipkinConfigurationLoader.class /cassandra/build/classes/main/ZipkinConfigurationLoader.class
ENV CASSANDRA_VERSION=2.2.1 SLF4J_VERSION=1.7.7 \
    JAVA=/usr/local/java/jre/bin/java \
    JVM_OPTS="-Dcassandra -Dorg.slf4j.simpleLogger.defaultLogLevel=info -Dcassandra.config.loader=ZipkinConfigurationLoader -Djava.net.preferIPv4Stack=true"

ADD install.sh /usr/local/bin/install
RUN /usr/local/bin/install

ADD run.sh /usr/local/bin/run.sh
CMD /usr/local/bin/run.sh

EXPOSE 9160 7000 7001 9042 7199
