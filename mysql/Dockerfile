# Share the same base image to reduce layers used in testing
FROM openzipkin/jre-full:1.8.0_152
MAINTAINER OpenZipkin "http://zipkin.io/"

WORKDIR /mysql
ADD install.sh /mysql/install
RUN /mysql/install

ENV ZIPKIN_VERSION 2.5.0

ADD configure.sh /mysql/configure
RUN /mysql/configure

ADD run.sh /mysql/run.sh
CMD /mysql/run.sh

EXPOSE 3306
