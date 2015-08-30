# Releasing a New Version

This document describes how to release a new set of Docker images for OpenZipkin.

1. **Update the Build Settings of the automated builds**

   Update the (git tag) - (docker tag) mapping on the Build Settings page of each affected project on Docker Hub.
   These are, unless something special happens: [`zipkin-base`](https://hub.docker.com/r/openzipkin/zipkin-base/~/settings/automated-builds/),
   [`zipkin-cassandra`](https://hub.docker.com/r/openzipkin/zipkin-cassandra/~/settings/automated-builds/),
   [`zipkin-collector`](https://hub.docker.com/r/openzipkin/zipkin-collector/~/settings/automated-builds/),
   [`zipkin-query`](https://hub.docker.com/r/openzipkin/zipkin-query/~/settings/automated-builds/), and
   [`zipkin-web`](https://hub.docker.com/r/openzipkin/zipkin-web/~/settings/automated-builds/).

    The tag mappings should look as follows:

  * Subminor releases (`1.2.2` -> `1.2.3`)
    * Create a new docker tag `1.2.3` pointing to the git tag you'll create (probably `1.2.3-rc1` on the first try)
    * Change the docker tag `1.2` to point to the git same git tag
  * Minor releases (`1.2.2` -> `1.3.1`)
    * Create a new docker tag `1.3` pointing to the git tag you'll create (probably `1.3.1-rc1` on the first try)
    * Create a new docker tag `1.3.1` pointing to the same git tag

1. **Bump the `ZIPKIN_VERSION` ENV var in `zipkin-base`**

   This will be used in various install scripts to pull in the right Zipkin release.

1. **Bump the version in `FROM` statement in `Dockerfile`s**

   For the projects that depend on `zipkin-base`, change their `Dockerfile`s to start building `FROM` the tag
   that will be created by this release. These are, unless something special happens: `cassandra`, `collector`, `query`, and `web`.
   At this point in time the images are not buildable, but that's fine. Sequencing the release steps this way
   saves some manual work, reducing the chance of mistakes (thus further saving manual work).

1. **Create, push the git tag**

   Make extra sure it's the same git tag you configured for the automated builds. Before pushing may be a good time
   to verify that the affected automated builds all have the same Build Settings.

   This starts the build of `zipkin-base`, which you can track under [openzipkin/zipkin-base](https://hub.docker.com/r/openzipkin/zipkin-base/builds/)

1. **Wait for `zipkin-base`**

   Once that's finished, it automatically triggers the build of `zikpin-cassandra`, `zipkin-collector`, `zipkin-query`, and `zipkin-web`.
   They'll use the newly built base image, since you've already changed their `FROM` statements to make it so.

1. **Wait for the rest of the images**

   As usual, you want to wait for: `zipkin-cassandra`, `zipkin-collector`, `zipkin-query`, and `zipkin-web`.

1. **Test the new images**

   Locally change `docker-compose.yml` to use the newly built versions, say `docker-compose up`, and verify
   that all is well with the world. TBD: How exactly do we do that?

1. **Commit, push `docker-compose.yml`**

1. **Done!**

   Congratulations, the intersection of the sets (OpenZipkin users) and (Docker users) can now enjoy the latest
   and greatest Zipkin release!
