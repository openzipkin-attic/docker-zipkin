FROM delitescere/jdk:8
MAINTAINER OpenZipkin "http://zipkin.io/"

RUN apk update && apk add netcat-openbsd curl

ENV ZIPKIN_REPO https://jcenter.bintray.com
ENV ZIPKIN_VERSION 1.17.2

RUN mkdir /zipkin
ADD .cassandra_profile /zipkin/.cassandra_profile
ADD .mysql_profile /zipkin/.mysql_profile

WORKDIR /zipkin
