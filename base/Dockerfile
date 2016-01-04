FROM openzipkin/jre-full:1.8.0_60
MAINTAINER OpenZipkin "http://zipkin.io/"

RUN apk update && apk add curl

ENV ZIPKIN_REPO https://jcenter.bintray.com
ENV ZIPKIN_VERSION 1.29.0
# Use to set heap, trust store or other system properties.
# Intentionally defaulted to empty string.
ENV JAVA_OPTS=

RUN mkdir /zipkin
ADD .cassandra_profile /zipkin/.cassandra_profile
ADD .http_profile /zipkin/.http_profile
ADD .kafka_profile /zipkin/.kafka_profile
ADD .mysql_profile /zipkin/.mysql_profile
ADD .scribe_profile /zipkin/.scribe_profile

WORKDIR /zipkin
