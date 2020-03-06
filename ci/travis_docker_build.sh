#!/bin/bash

set -o nounset
set -o errexit

## common build args for TravisCI builds
TRAVIS_BUILDARGS=(--build-arg TRAVIS=${TRAVIS} --build-arg TRAVIS_JOB_ID=${TRAVIS_JOB_ID})

echo "[travis_docker_build] running base docker build"
docker build ${TRAVIS_BUILDARGS[@]} --target build .

# push docker images when not executing a PR build
if [[ "${TRAVIS_PULL_REQUEST}" = "false" ]]; then
  docker_tag="${TRAVIS_TAG:-latest}"

  echo "[travis_docker_build] Packaging docker images for tag ${docker_tag}"
  docker build ${TRAVIS_BUILDARGS[@]}\
               --tag ${TRAVIS_REPO_SLUG}:${docker_tag}\
               --tag quay.io/${TRAVIS_REPO_SLUG}:${docker_tag}\
               --target package .

  ## setup different build args if the build is for a snapshot or a tag
  PUBLISH_OPTS=(--build-arg TRAVIS=${TRAVIS} --build-arg TRAVIS_JOB_ID=${TRAVIS_JOB_ID} --build-arg BUILDKIT_INLINE_CACHE=1 --build-arg JFROG_DEPLOY_USER=${JFROG_DEPLOY_USER} --build-arg JFROG_DEPLOY_KEY=${JFROG_DEPLOY_KEY})
  if [[ ! -z "${TRAVIS_TAG+x}" ]]; then
    PUBLISH_OPTS+=(--build-arg BINTRAY_PUBLISH=true --build-arg APP_VERSION=${TRAVIS_TAG})
  fi
  echo "[travis_docker_build] Uploading maven artifacts"
  docker build ${TRAVIS_BUILDARGS[@]} ${PUBLISH_OPTS[@]} --target publish .

  echo "[travis_docker_build] dockerhub push for tag ${docker_tag}"
  docker login -u="${DOCKERHUB_USER}" -p="${DOCKERHUB_PASS}"
  docker push ${TRAVIS_REPO_SLUG}:${docker_tag}

  echo "[travis_docker_build] quay.io push for tag ${docker_tag}"
  docker login -u="${QUAYIO_USER}" -p="${QUAYIO_PASS}" quay.io
  docker push quay.io/${TRAVIS_REPO_SLUG}:${docker_tag}
else
  echo "[travis_docker_build] Skipping Docker and Maven publish for PR build"
fi
