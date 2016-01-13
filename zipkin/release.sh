#!/bin/bash

set -ueo pipefail

# Check the environment
if ! which jq >/dev/null 2>/dev/null; then
    echo "The release script requires jq (https://stedolan.github.io/jq/) to run."
    echo "Ideas: "
    echo
    echo "    brew install jq"
    echo "    apt-get install jq"
    exit 1
fi

if [[ "$(uname)" == 'Darwin' ]]; then
    if ! which gdate >/dev/null 2>/dev/null; then
        echo "It appears you're on OSX and don't have GNU Coreutils installed, which is required by this release script."
        echo "Please install it and re-run this script:"
        echo
        echo "    brew install coreutils"
        exit 1
    fi
    date=gdate
else
    date=date
fi

# Constants
api="https://quay.io/api/v1"
started_at=$($date +%s)

## Read input and env
version="$1"
# Service images
image="${IMAGE_NAME:-zipkin-java}"
# Remotes, auth
docker_organization="${DOCKER_ORGANIZATION:-openzipkin}"
quayio_oauth2_token="$QUAYIO_OAUTH2_TOKEN"
git_remote="${GIT_REMOTE:-origin}"
target_git_branch="${TARGET_GIT_BRANCH:-master}"

prefix() {
    while read line; do
        echo "[$($date +"%x %T")][${1}] $line"
    done
}

checkout-target-branch () {
    git fetch "$git_remote" "$target_git_branch"
    git checkout -B "$target_git_branch"
}

fetch-last-build () {
    local tag="$1"
    local image="$2"
    local repo="${docker_organization}/${image}"

    curl -s "${api}/repository/${repo}/build/" | jq ".builds | map(select(.tags | contains([\"${tag}\"])))[0]"
}

wait-for-build-to-start () {
    local tag="$1"
    local image="$2"
    local repo="${docker_organization}/${image}"

    timeout=300
    while [[ "$timeout" -gt 0 ]]; do
        echo >&2 "Waiting for the build of $image for version $tag to start for $timeout more seconds..."
        build="$(fetch-last-build "$tag" "$image")"
        if [[ "$build" != "null" ]]; then
            build_id=$(echo "$build" | jq '.id' -r)
            echo >&2 "Build started: https://quay.io/repository/$repo/build/$build_id"
            echo "$build_id"
            return
        fi
        timeout=$(($timeout - 10))
        sleep 10
    done

    echo "Build didn't start in a minute (or I failed to recognized it). Bailing out."
    return 1
}

wait-for-build-to-finish () {
    local image="$1"
    local build_id="$2"

    echo "Waiting for build of $image with tag $tag to finish..."
    while true; do
        phase="$(curl -s "${api}/repository/${docker_organization}/${image}/build/${build_id}" | jq '.phase' -r)"
        if [[ "$phase" == 'complete' ]]; then
            echo "Build completed."
            return
        elif [[ "$phase" == 'error' ]]; then
            echo "Build failed. Bailing out."
            exit 1
        else
            echo "Build of $image is in phase \"${phase}\", waiting..."
            sleep 10
        fi
    done
}

wait-for-builds () {
    local tag="$1"; shift
    local images="$@"
    for image in $images; do
        echo "Waiting for build of $image with tag $tag"
        build_id="$(wait-for-build-to-start "$tag" "$image")"
        wait-for-build-to-finish "$image" "$build_id"
    done
}

sync-quay-tag () {
    local repo="${docker_organization}/$1"
    local reference_tag="$2"
    local tag_to_move="$3"

    echo "Syncing tag ${tag_to_move} to ${reference_tag} on ${repo}"
    image_id="$(curl -s "${api}/repository/${repo}/tag/${reference_tag}/images" | jq '.images | sort_by(-.sort_index)[0].id' -r)"
    echo "Image id is ${image_id}"
    curl -s "${api}/repository/${repo}/tag/${tag_to_move}" \
         -H "Authorization: Bearer $quayio_oauth2_token" \
         -H "Content-Type: application/json" \
         -XPUT -d "{\"image\": \"$image_id\"}"
    echo
}

sync-quay-tags () {
    local reference_tag="$1"; shift
    local tags_to_move="$1"; shift
    local images="$@"

    for image in $images; do
        for tag_to_move in $tags_to_move; do
            sync-quay-tag "$image" "$reference_tag" "$tag_to_move"
        done
    done
}

sync-to-dockerhub () {
    local tag="$1"; shift
    local images="$@"
    for image in $images; do
        dockerhub_name="${docker_organization}/${image}:${tag}"
        quay_name="quay.io/${dockerhub_name}"
        echo "Syncing ${quay_name} to Docker Hub as ${dockerhub_name}"
        docker pull "$quay_name"
        docker tag -f "$quay_name" "$dockerhub_name"
        retry 3 docker push "$dockerhub_name"
    done
}

retry () {
    local limit="$1"; shift
    local cmd="$@"
    local tries=1
    while [[ $tries -lt $limit ]]; do
        if ! $cmd; then
            tries=$(($tries + 1))
            echo "\"$cmd\" failed, try $tries/$limit coming up"
        else
            break
        fi
    done
    if [[ $tries -eq $limit ]]; then
        echo "\"$cmd\" failed $limit times, aborting."
        return 1
    fi
}

main () {
    # Check that the version is something we like
    if ! echo "$version" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' -q; then
        echo "Usage: $0 <version>"
        echo "Where version must be <major>.<minor>.<subminor>"
        exit 1
    fi

    # The git tags we'll create
    major_tag=$(echo "$version" | cut -f1 -d. -s)
    minor_tag=$(echo "$version" | cut -f1-2 -d. -s)
    subminor_tag="$version"

    action_plan="
    checkout-target-branch                                                        2>&1 | prefix checkout-target-branch
    wait-for-builds         $subminor_tag $image                                  2>&1 | prefix wait-for-build
    sync-quay-tags          $subminor_tag \"$minor_tag $major_tag latest\" $image 2>&1 | prefix sync-quay-tags
    sync-to-dockerhub       $subminor_tag $image                                  2>&1 | prefix sync-${subminor_tag}-to-dockerhub
    sync-to-dockerhub       $minor_tag $image                                     2>&1 | prefix sync-${minor_tag}-to-dockerhub
    sync-to-dockerhub       $major_tag $image                                     2>&1 | prefix sync-${major_tag}-to-dockerhub
    sync-to-dockerhub       latest $image                                         2>&1 | prefix sync-latest-to-dockerhub
    "

    echo "Starting release $version. Action plan:"
    echo "$action_plan" | sed -e 's/ *2>&1.*//'

    eval "$action_plan"

    echo
    echo "All done. Now it's time to update docker-compose.yml with the new version and validate that the new image works."
    echo "Once you're done with that:"
    echo
    echo "    git commit docker-compose.yml -m 'Release $version'; git push"
}

main

