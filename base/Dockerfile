FROM debian:sid
MAINTAINER Zero Cho "http://itsze.ro"

RUN apt-get update && apt-get install -y \
  curl \
  openjdk-8-jre-headless \
  netcat

ENV ZIPKIN_REPO https://jcenter.bintray.com
ENV ZIPKIN_VERSION 1.2.2

RUN mkdir /zipkin
WORKDIR /zipkin
