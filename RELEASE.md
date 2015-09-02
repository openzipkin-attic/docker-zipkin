# Releasing a New Version

This document describes how to release a new set of Docker images for OpenZipkin. The images are built automatically
on [quay.io](https://quay.io) and mirrored to Docker Hub.

## Tag structure

Each release is tagged with a semantic version number like `1.4.1`. The Docker tags `1.4` and `1` point to the latest
tag under them, to let users choose the level of version pinning they prefer.

## Release using Travis (recommended)

1. **Create, push a tag `release-1.4.1`**

   This triggers a Travis job on [openzipkin/docker-zipkin](https://travis-ci.org/openzipkin/docker-zipkin)
   that just takes care of everything, except for:

1. **Test the new images**

   Locally change `docker-compose.yml` to use the newly built versions (the tag will be something like `1.4.1`),
   execute `docker-compose up`, and verify that all is well with the world. TBD: How exactly do we do that?

1. **Commit, push `docker-compose.yml`**

1. **There is no step four**

   Congratulations, the intersection of the sets (OpenZipkin users) and (Docker users) can now enjoy the latest
   and greatest Zipkin release!

## Release manually (not recommended)

1. **Get a Quay.io OAuth 2 token**

   Go to https://quay.io/organization/openzipkin/application/QREQHLDQGW2LI4OGGD6C?tab=gen-token and generate a token
   with "Read/Write to any accessible repositories" permissions. Export this token to be used by the release script:
   `export QUAYIO_OAUTH2_TOKEN='...'`

   This token will be used to sync up the Docker tags `1` and `1.4` when you release `1.4.1`.

1. **Activate your Docker environment**

   Make sure you have `$DOCKER_HOST` and friends set. The easiest way to check this is to run `docker version`, which
   will print the version of your Docker daemon as well as your server. For many people, `eval $(docker-machine env dev)`
   or some slight variation will take care of this.

1. **Log in to Docker Hub**

   Make sure your Docker client configuration has your credentials to hub.docker.com. The easiest way to get this right
   is to issue the command `docker login` and enter your credentials.

   This will be used when syncing the built images from Quay.io to Docker Hub.

1. **Run `release.sh $RELEASE_TAG`**

   `RELEASE_TAG` should be a semantic version number prefixed by `release-`, like `release-1.4.1`. Go grab a coffee.

   The script will create a Git tag `base-1.4.1` that triggers the build of `zipkin-base`, wait for that build, then
   create another Git tag `1.4.1` that triggers the rest of the builds. It waits for those, then syncs up the Docker
   tags `1` and `1.4` to the Docker tag `1.4.1` created by these builds. Finally it syncs the built images to Docker Hub.

1. **Test the new images**

   Locally change `docker-compose.yml` to use the newly built versions, say `docker-compose up`, and verify
   that all is well with the world. TBD: How exactly do we do that?

1. **Commit, push `docker-compose.yml`**

1. **Done!**

   Congratulations, you're done!

## What happens inside `release.sh`?

Assume we're releasing `1.4.1`.

 * The ENV var `ZIPKIN_VERSION` in the `Dockerfile` of `zipkin-base` is updated, committed and pushed
 * The tag `base-1.4.1` is created and pushed. The quay.io repository for `zipkin-base` is configured to trigger a build
   on tags starting with `base-`.
 * The script waits for the build to start using the quay.io API to poll for it (timing out after 5 minutes), and then
   waits for it to finish (never timing out). The heuristics used to identify the build we want: it's the latest build
   started after `release.sh` has started for the tag we're building.
 * The `Dockerfile`s of the services are updated so that their base image is the image that's just been built on quay.io,
   committed and pushed.
 * The tag `1.4.1` is created and pushed. The quay.io repositories for the services (`zipkin-cassandra`, `zipkin-collector`,
   `zipkin-query`, and `zipkin-web`) are configured to trigger a build on tags that look match `\d+\.\d+\.\d+`.
 * The script waits for the build of each build to start (timeout 5 minutes) and finish (no timeout) using the quay.io
   API to poll for them. It does this one by one for each build, so usually there's only any waiting for the first service;
   the rest are also about done by the time that's finished.
 * The tag `base-1.4.1` for `zipkin-base` and the tags `1`, `1.4`, `1.4.1` for the services are synced to Docker Hub by
   pulling them from quay.io using the `docker` CLI and pushing them to Docker Hub.
 * A friendly message is printed to remind the release manager (HAH! Such words.) about manually testing the release
   and updating the tags in `docker-compose.yml`. This last part could definitely use more automation.
