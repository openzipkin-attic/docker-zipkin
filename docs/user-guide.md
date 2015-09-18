# Docker toolbox & docker-zipkin on Mac OS X

## Installation

* Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (`5.0.3+`).

* Install [Docker Toolbox](https://www.docker.com/toolbox).
  * if afterwards the `Docker Quickstart Terminal` doesn't work the docker machine might be botched (incompatible VirtualBox version etc), see the next section.

## Configuration of Docker

```sh
docker-machine ls
# NAME      ACTIVE   DRIVER       STATE     URL   SWARM
# default            virtualbox   Stopped

docker-machine start default
# Starting VM...
# Started machines may have new IP addresses. You may need to re-run the `docker-machine env` command.

docker-machine ls
# NAME      ACTIVE   DRIVER       STATE     URL                         SWARM
# default            virtualbox   Running   tcp://192.168.99.100:2376

docker-machine env default
# export DOCKER_TLS_VERIFY="1"
# export DOCKER_HOST="tcp://192.168.99.101:2376"
# export DOCKER_CERT_PATH="/Users/jfeltesse/.docker/machine/machines/default"
# export DOCKER_MACHINE_NAME="default"
# # Run this command to configure your shell:
# # eval "$(docker-machine env default)"

eval "$(docker-machine env default)"
# (no output)

docker run hello-world
# should pull and run the hello-world image
```

### Machine not working

If `docker-machine env default` throws an error (missing ca.pem file and such) try to re-create the default machine by running:

```sh
docker-machine rm default
docker-machine create --driver virtualbox default
```


## Running docker-zipkin

After going successfully through the docker configuration, the system is ready to give that docker-zipkin project a try!

```sh
git clone git@github.com:openzipkin/docker-zipkin.git
cd docker-zipkin
```

Before actually starting the machine check it is active

```sh
docker-machine ls
# NAME      ACTIVE   DRIVER       STATE     URL                         SWARM
# default   *        virtualbox   Running   tcp://192.168.99.101:2376
```

If it's not then simply do `docker-machine env default && eval "$(docker-machine env default)"`

At this point `docker ps` should output a blank table because nothing is running.

Run `docker-compose up` in the docker-zipkin directory (so it picks up the `docker-compose.yml` file) and wait until it's done downloading everything and flooding the console with all sorts of messages.

Now `docker ps` should display something like

```
CONTAINER ID        IMAGE                             COMMAND                  CREATED             STATUS              PORTS                                                       NAMES
eaebf259371e        openzipkin/zipkin-web:1.4         "/usr/local/bin/run"     2 hours ago         Up 48 minutes       0.0.0.0:8080->8080/tcp, 0.0.0.0:9990->9990/tcp              dockerzipkin_web_1
1ff314120b85        openzipkin/zipkin-collector:1.4   "/usr/local/bin/run.s"   2 hours ago         Up 48 minutes       0.0.0.0:9410->9410/tcp, 0.0.0.0:9900->9900/tcp              dockerzipkin_collector_1
31053fe3e5c0        openzipkin/zipkin-query:1.4       "/usr/local/bin/run.s"   2 hours ago         Up 48 minutes       0.0.0.0:9411->9411/tcp, 0.0.0.0:9901->9901/tcp              dockerzipkin_query_1
32dad2be5775        openzipkin/zipkin-cassandra:1.4   "/usr/local/bin/run"     2 hours ago         Up 48 minutes       7000-7001/tcp, 7199/tcp, 9160/tcp, 0.0.0.0:9042->9042/tcp   dockerzipkin_cassandra_1
```

The web part of this machinery is running on port 8080 and 9990:

```sh
docker port dockerzipkin_web_1
# 8080/tcp -> 0.0.0.0:8080
# 9990/tcp -> 0.0.0.0:9990
```

But you can't simply access these using localhost because
> “[...] your DOCKER_HOST address is not the localhost address (0.0.0.0) but is instead the address of the your Docker VM.” [→ source](http://docs.docker.com/installation/mac/#example-of-docker-on-mac-os-x)

To get the proper ip run `docker-machine ip default` and access it on port 8080.

Zipkin's top page should come up!

## Upgrading docker-zipkin

Just sync your local repo and run `docker-compose up` again.
It will automagically download the images in the containers' docker files and run the machine.

## Zipkin's storage schema

- [Cassandra](https://github.com/openzipkin/zipkin/blob/master/zipkin-cassandra-core/src/main/resources/cassandra-schema-cql3.txt)
- [MySQL](https://github.com/openzipkin/zipkin/blob/master/zipkin-anormdb/src/main/resources/mysql.sql)
- [Other anormDB supported databases](https://github.com/openzipkin/zipkin/blob/master/zipkin-anormdb/src/main/scala/com/twitter/zipkin/storage/anormdb/DB.scala) (see `install` method)

## Connecting to the storage directly

### Cassandra

```
brew install cassandra
```

Then run the following to connect:

```sh
cqlsh `docker-machine ip default` --cqlversion=3.2.0
```

