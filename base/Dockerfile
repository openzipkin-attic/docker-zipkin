FROM openzipkin/jre-full:1.8.0_60
MAINTAINER OpenZipkin "http://zipkin.io/"

RUN apk update && apk add netcat-openbsd curl

ENV ZIPKIN_REPO https://jcenter.bintray.com
ENV ZIPKIN_VERSION 1.18.1

RUN mkdir /zipkin
ADD .cassandra_profile /zipkin/.cassandra_profile
ADD .kafka_profile /zipkin/.kafka_profile
ADD .mysql_profile /zipkin/.mysql_profile
ADD .scribe_profile /zipkin/.scribe_profile

WORKDIR /zipkin
