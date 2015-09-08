FROM delitescere/java:8
MAINTAINER OpenZipkin "http://zipkin.io/"

RUN apk update && apk add netcat-openbsd curl

# Temporary until https://jcenter.bintray.com is re-enabled for zipkin
ENV ZIPKIN_REPO https://dl.bintray.com/openzipkin/zipkin
ENV ZIPKIN_VERSION 1.5.1

RUN mkdir /zipkin
WORKDIR /zipkin
