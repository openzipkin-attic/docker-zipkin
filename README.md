# docker-zipkin

[![Build Status](https://travis-ci.org/openzipkin/docker-zipkin.svg)](https://travis-ci.org/openzipkin/docker-zipkin)
[![zipkin-base](https://quay.io/repository/openzipkin/zipkin-base/status "zipkin-base")](https://quay.io/repository/openzipkin/zipkin-base)
[![zipkin-cassandra](https://quay.io/repository/openzipkin/zipkin-cassandra/status "zipkin-cassandra")](https://quay.io/repository/openzipkin/zipkin-cassandra)
[![zipkin-collector](https://quay.io/repository/openzipkin/zipkin-collector/status "zipkin-collector")](https://quay.io/repository/openzipkin/zipkin-collector)
[![zipkin-query](https://quay.io/repository/openzipkin/zipkin-query/status "zipkin-query")](https://quay.io/repository/openzipkin/zipkin-query)
[![zipkin-web](https://quay.io/repository/openzipkin/zipkin-web/status "zipkin-web")](https://quay.io/repository/openzipkin/zipkin-web)

Dockerfiles for starting a Zipkin instance backed by Cassandra. Automatically built images are available on Quay.io
under the [OpenZipkin](https://quay.io/organization/openzipkin) organization, and are mirrored to
[Docker Hub](https://hub.docker.com/u/openzipkin/).

## docker-compose

This project is configured to run docker containers using
[docker-compose](https://docs.docker.com/compose/).

To start the default docker-compose configuration, run:

    $ docker-compose up

See the ui at (docker ip):8080

In the ui - click zipkin-query, then click "Find Traces"

### Cassandra

The default docker-compose configuration defined in `docker-compose.yml` is
backed by a single-node Cassandra. This configuration starts each of the Zipkin
services in their own containers: `zipkin-cassandra`, `zipkin-query`, and
`zipkin-web`, and only links required dependencies together.

### MySQL

The docker-compose configuration can be extended to use MySQL instead of
Cassandra, using the `docker-compose-mysql.yml` file. That file employs
[docker-compose overrides](https://docs.docker.com/compose/extends/#multiple-compose-files)
to swap out one storage container for another.

To start the MySQL-backed configuration, run:

    $ docker-compose -f docker-compose.yml -f docker-compose-mysql.yml up

## Notes

All images share a base image, 
`zipkin-base`, which is built on the Alpine-based image [`delitescere/java:8`] (https://github.com/delitescere/docker-zulu), which is much smaller than the previously used `debian:sid`-based image.

`zipkin-collector`, `zipkin-query`, and `zipkin-web` honor the environment variable `JAVA_OPTS`, which can be used to set heap size, trust store location or other JVM system properties.

## Connecting to Span Storage

`zipkin-collector` and `zipkin-query` store and retrieve spans from Cassandra, using its native protocol. Specify a list of one or more Cassandra nodes listening on port 9042, via the comma-separated environment variable `CASSANDRA_CONTACT_POINTS`.

ex. 
```bash
docker run -d -p 9410:9410 -p 9900:9900 --name="zipkin-collector" -e "CASSANDRA_CONTACT_POINTS=node1,node2,node3" "openzipkin/zipkin-collector:latest"
```
