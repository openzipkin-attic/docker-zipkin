# Releasing a New Version

This document describes how to release a new set of Docker images for OpenZipkin. The images are built automatically
on [quay.io](https://quay.io) and mirrored to Docker Hub.

## Tag structure

Each release is tagged with a semantic version number like `1.4.1`. The Docker tags `1.4` and `1` point to the latest
tag under them, to let users choose the level of version pinning they prefer.

## Release process

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

1. **Run `release.sh $VERSION`**

   Version should be a semantic version number, like `1.4.1`. Go grab a coffee.

   The script will create a Git tag `base-1.4.1` that triggers the build of `zipkin-base`, wait for that build, then
   create another Git tag `1.4.1` that triggers the rest of the builds. It waits for those, then syncs up the Docker
   tags `1` and `1.4` to the Docker tag `1.4.1` created by these builds. Finally it syncs the built images to Docker Hub.

1. **Test the new images**

   Locally change `docker-compose.yml` to use the newly built versions, say `docker-compose up`, and verify
   that all is well with the world. TBD: How exactly do we do that?

1. **Commit, push `docker-compose.yml`**

1. **Done!**

   Congratulations, the intersection of the sets (OpenZipkin users) and (Docker users) can now enjoy the latest
   and greatest Zipkin release!

