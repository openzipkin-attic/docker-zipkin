# Releasing a New Version

This document describes how to release a new Docker image for Java Zipkin
backend. The images are built automatically on [quay.io](https://quay.io) and
mirrored to Docker Hub.

## Tag structure

Each release is tagged with a semantic version number like `1.4.1`. The Docker
tags `1.4` and `1` point to the latest tag under them, to let users choose the
level of version pinning they prefer.

## Release using Travis (recommended)

1. **Create, push a tag `1.4.1`**

   This triggers a Travis job on [openzipkin/docker-zipkin-java](https://travis-ci.org/openzipkin/docker-zipkin-java)
   that just takes care of everything, except for:

1. **Test the new images**

   Locally change `docker-compose.yml` to use the newly built version in the
   container `query` (the tag will be something like `1.4.1`), execute
   `docker-compose up`, and verify that all is well with the world.

1. **Commit, push `docker-compose.yml`**

1. **There is no step four**

   Congratulations, the intersection of the sets (openzipkin/zipkin-java users) and (Docker
   users) can now enjoy the latest and greatest Zipkin Java release!


## What happens when I push a tag?

Assume we're releasing `1.4.1`, so you've just pushed the tag `1.4.1`.

* A build of the image `openzipkin/zipkin-java` is triggered on Quay.io, which will build the image and tag it with `1.4.1`.
  The build is configured to trigger when tags matching `^[0-9]+\.[0-9]+\.[0-9]+$` are pushed.
* A build of the GitHub repository `openzipkin/docker-zipkin-java` is triggered on Travis CI. The build starts `release.sh`, which
   * Waits for the Quay.io build to start using the Quay.io API to poll for it (timing out after 5 minutes), and then
     waits for it to finish (never timing out). The heuristic used to identify the build we want: it's the latest build
     started for the tag we're building.
   * Syncs the tags `1`, `1.4`, and `latest` to the tag `1.4.1` on Quay.io.
   * Syncs the tags `1`, `1.4`, `1.4.1` for `zipkin-java` to Docker Hub by pulling them from quay.io using the `docker` CLI and
     pushing them to Docker Hub.
   * A friendly message is printed to remind the release manager (HAH! Such words.) about manually testing the release
     and updating the tags in `docker-compose.yml`. This last part could definitely use more automation.
