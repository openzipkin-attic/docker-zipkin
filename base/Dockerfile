FROM debian:sid
MAINTAINER Zero Cho "http://itsze.ro"

RUN apt-get update
RUN apt-get install -y scala git curl openjdk-7-jdk

ADD zipkin /zipkin
WORKDIR /zipkin
RUN ./gradlew installDist -x test

