FROM delitescere/java:8
MAINTAINER OpenZipkin "http://zipkin.io/"

RUN apk update && apk add netcat-openbsd curl

ENV ZIPKIN_REPO https://jcenter.bintray.com
ENV ZIPKIN_VERSION 1.9.0

RUN mkdir /zipkin
WORKDIR /zipkin

# Temporary until Hikari no longer uses the {@code java.beans} api.
# https://github.com/brettwooldridge/HikariCP/issues/415
RUN mkdir -p /zipkin/anormpatch/com/twitter/zipkin/storage/anormdb && \
    curl -SL https://repo1.maven.org/maven2/org/apache/commons/commons-pool2/2.4.2/commons-pool2-2.4.2.jar > /zipkin/anormpatch/commons-pool2.jar && \
    curl -SL https://repo1.maven.org/maven2/org/apache/commons/commons-dbcp2/2.1.1/commons-dbcp2-2.1.1.jar > /zipkin/anormpatch/commons-dbcp2.jar
ADD DataSource.class /zipkin/anormpatch/com/twitter/zipkin/storage/anormdb/DataSource.class
ENV ANORMPATCH_CLASSPATH /zipkin/anormpatch/commons-pool2.jar:/zipkin/anormpatch/commons-dbcp2.jar:/zipkin/anormpatch
