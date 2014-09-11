FROM itszero/zipkin-base
MAINTAINER Zero Cho "http://itsze.ro"

ADD collector-cassandra.scala /zipkin/zipkin-collector-service/config/collector-cassandra.scala
ADD run.sh /usr/local/bin/run
ENTRYPOINT ["/usr/local/bin/run"]

EXPOSE 9410
