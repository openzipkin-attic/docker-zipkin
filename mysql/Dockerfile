FROM alpine
MAINTAINER Zipkin "https://zipkin.apache.org/"

WORKDIR /mysql
ADD install.sh /mysql/install
RUN /mysql/install

ENV ZIPKIN_VERSION 2.14.0

ADD configure.sh /mysql/configure
RUN /mysql/configure

ADD run.sh /mysql/run.sh
CMD /mysql/run.sh

EXPOSE 3306
