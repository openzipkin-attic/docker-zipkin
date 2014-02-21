# docker-zipkin

Dockerfiles for start a Zipkin instance backed by Cassandra

## Build Images

Please run `cd deploy; ./build.sh` to build the images on your own computer. You may change the **PREFIX** in build.sh and deploy.sh as you see fit.

## Deploy Zipkin

Before you start, please edit the `deploy.sh` to change the URL to match your Docker host IP, you may also change the port if needed. Now, run `cd deploy; ./deploy.sh` to start a complete Zipkin instance. If you did not build the images before, you will pull the published images from Docker INDEX.

Note that if you changed PREFIX in build.sh to build your own images, you need to make same changes here in deploy.sh. Otherwise, it will still use the standard images pushed by me.

## Architecture

Docker-Zipkin starts the services in their own container: zipkin-cassandra, zipkin-collector, zipkin-query, zipkin-web. All images with the exception of zipkin-cassandra are sharing a base image: **zipkin-base**. Zipkin-base and Zipkin-cassandra is built on **debian:sid**.

## Author

Zero Cho <itszero@gmail.com>
