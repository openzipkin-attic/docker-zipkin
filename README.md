# docker-zipkin

[![Build Status](https://travis-ci.org/openzipkin/docker-zipkin.svg)](https://travis-ci.org/openzipkin/docker-zipkin)
[![zipkin-base](https://quay.io/repository/openzipkin/zipkin-base/status "zipkin-base")](https://quay.io/repository/openzipkin/zipkin-base)
[![zipkin-cassandra](https://quay.io/repository/openzipkin/zipkin-cassandra/status "zipkin-cassandra")](https://quay.io/repository/openzipkin/zipkin-cassandra)
[![zipkin-collector](https://quay.io/repository/openzipkin/zipkin-collector/status "zipkin-collector")](https://quay.io/repository/openzipkin/zipkin-collector)
[![zipkin-query](https://quay.io/repository/openzipkin/zipkin-query/status "zipkin-query")](https://quay.io/repository/openzipkin/zipkin-query)
[![zipkin-web](https://quay.io/repository/openzipkin/zipkin-web/status "zipkin-web")](https://quay.io/repository/openzipkin/zipkin-web)

This project contains Dockerfiles for producing images for each of the
components in a full Zipkin stack.  Automatically built images are available on
Quay.io under the [OpenZipkin](https://quay.io/organization/openzipkin) organization,
and are mirrored to [Docker Hub](https://hub.docker.com/u/openzipkin/).

## docker-compose

This project is configured to run docker containers using
[docker-compose](https://docs.docker.com/compose/). Note that the default
configuration requires docker-compose 1.6.0+ and docker-engine 1.10.0+. If you
are running older versions, see the [Legacy](#legacy) section below.

To start the default docker-compose configuration, run:

    $ docker-compose up

View the web UI at $(docker ip):8080.

To see specific traces in the UI, select "zipkin-query" in the dropdown and
then click the "Find Traces" button.

### Cassandra

The default docker-compose configuration defined in `docker-compose.yml` is
backed by a single-node Cassandra. This configuration starts each of the Zipkin
services in their own containers: `zipkin-cassandra`, `zipkin-query`, and
`zipkin-web`, and configures required dependencies.

### MySQL

The docker-compose configuration can be extended to use MySQL instead of
Cassandra, using the `docker-compose-mysql.yml` file. That file employs
[docker-compose overrides](https://docs.docker.com/compose/extends/#multiple-compose-files)
to swap out one storage container for another.

To start the MySQL-backed configuration, run:

    $ docker-compose -f docker-compose.yml -f docker-compose-mysql.yml up

### Legacy

The Cassandra and MySQL docker-compose files described above use version 2 of
the docker-compose config file format. There is a legacy version 1 configuration
also available, in the `docker-compose-legacy.yml` file. That configuration
relies on container linking, and runs the legacy `zipkin-collector` container.

To start the legacy configuration, run:

    $ docker-compose -f docker-compose-legacy.yml up

## Runtime configuration

Most runtime configuration is handled with environment variables. Some of the
available environment variables are not docker-specific, and as such they are
documented in the main Zipkin repo, as follows:

* [zipkin-cassandra](https://github.com/openzipkin/zipkin/tree/master/zipkin-cassandra#service-configuration)
* [zipkin-collector](https://github.com/openzipkin/zipkin/blob/master/zipkin-collector-service/README.md#configuration)
* [zipkin-query](https://github.com/openzipkin/zipkin/blob/master/zipkin-query-service/README.md#configuration)
* [zipkin-web](https://github.com/openzipkin/zipkin/blob/master/zipkin-web/README.md#configuration)

Additionally, docker-specific environment variables are described below. See the
docker-compose files for additional examples of how these variables may be set.

### Storage

Both the `zipkin-query` and the `zipkin-collector` containers need to be
configured to talk to a storage. The backend is determined by the `STORAGE_TYPE`
environment variable, and the available values are "cassandra" or "mysql".

If `STORAGE_TYPE=cassandra`, then the container expects for one of these two
additional environment variables to be set:

* `CASSANDRA_CONTACT_POINTS` -- A comma-separated list of one or more Cassandra
  nodes listening on port 9042.
* `STORAGE_PORT_9042_TCP_ADDR` -- A Cassandra node listening on port 9042. This
  environment variable is typically set by linking a container running
  `zipkin-cassandra` as "storage" when you start the container.

If `STORAGE_TYPE=mysql`, then the container expects for one of these two
additional environment variables to be set:

* `MYSQL_HOST` -- A MySQL node listening on port 3306.
* `STORAGE_PORT_3306_TCP_ADDR` -- A MySQL node listening on port 3306. This
  environment variable is typically set by linking a container running
  `zipkin-mysql` as "storage" when you start the container.

### Transport

The `zipkin-query`, `zipkin-collector` and `zipkin-web` containers use the
`TRANSPORT_TYPE` environment variable to configure how they send and receive
data.

For the query and web containers, if `TRANSPORT_TYPE=http`, then those
containers will send trace data via http to the `zipkin-query` service. If
`TRANSPORT_TYPE=scribe`, then  those containers will send trace data via scribe
to the `zipkin-collector` service. If `TRANSPORT_TYPE` is unset, then those
containers will not trace requests that they receive.

For the collector container, if `TRANSPORT_TYPE=scribe`, then the container will
run a scribe collector on port 9410. If `TRANSPORT_TYPE=kafka`, then the
container will poll Kafka, and expects one of these two additional environment
variables to be set:

* `KAFKA_ZOOKEEPER` -- A node and port where Zookeeper is running.
* `KAFKA_PORT_2181_TCP_ADDR` -- A zookeeper node listening on port 2181. This
  environment variable is typically set by linking a container running
  `zipkin-kafka` as "kafka" when you start the container.

### JAVA_OPTS

The `zipkin-collector`, `zipkin-query`, and `zipkin-web` containers honor the
`JAVA_OPTS` environment variable, which can be used to set heap size, trust
store location or other JVM system properties.

## Notes

All images share a base image, `zipkin-base`, which is built on the Alpine-based
image [`delitescere/java:8`](https://github.com/delitescere/docker-zulu), which
is much smaller than the previously used `debian:sid`-based image.
