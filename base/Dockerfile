FROM delitescere/jdk:8
MAINTAINER OpenZipkin "http://zipkin.io/"

RUN apk update && apk add netcat-openbsd curl

ENV ZIPKIN_REPO https://jcenter.bintray.com
ENV ZIPKIN_VERSION 1.16.1

RUN mkdir /zipkin
WORKDIR /zipkin
