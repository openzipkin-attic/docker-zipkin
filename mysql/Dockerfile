FROM quay.io/openzipkin/zipkin-base:base-1.30.1
MAINTAINER OpenZipkin "http://zipkin.io/"

WORKDIR /mysql
ADD install.sh /mysql/install
RUN /mysql/install

ADD run.sh /mysql/run.sh
CMD /mysql/run.sh

EXPOSE 3306
