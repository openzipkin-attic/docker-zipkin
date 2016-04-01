FROM quay.io/openzipkin/zipkin-base:base-1.39.1
MAINTAINER OpenZipkin "http://zipkin.io/"

# Temporarily hard-code zipkin's configuration to a class that looks up the container's IP
ADD ZipkinConfigurationLoader.class /cassandra/build/classes/main/ZipkinConfigurationLoader.class
ENV CASSANDRA_VERSION=2.2.3 \
    JAVA=/usr/local/java/jre/bin/java \
    JVM_OPTS="-Dcassandra -Dcassandra.config.loader=ZipkinConfigurationLoader -Djava.net.preferIPv4Stack=true"

ADD install.sh /usr/local/bin/install
RUN /usr/local/bin/install

ADD run.sh /usr/local/bin/run.sh
CMD /usr/local/bin/run.sh

EXPOSE 9160 7000 7001 9042 7199
