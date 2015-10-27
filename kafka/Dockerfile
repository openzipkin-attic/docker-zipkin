FROM quay.io/openzipkin/zipkin-base:base-1.19.1
MAINTAINER OpenZipkin "http://zipkin.io/"

ENV SCALA_VERSION 2.11
ENV KAFKA_VERSION 0.8.2.2
ENV ZOOKEEPER_VERSION 3.4.6

WORKDIR /kafka
ADD install.sh /kafka/install
RUN /kafka/install

EXPOSE 2181 9092

CMD ["runsvdir", "/etc/service"]
