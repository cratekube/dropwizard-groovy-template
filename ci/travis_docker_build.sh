#!/bin/bash

set -o nounset
set -o errexit

echo "### Running docker build"
echo
docker build --build-arg TRAVIS=${TRAVIS} --build-arg TRAVIS_JOB_ID=${TRAVIS_JOB_ID} --target Build .

## push docker images when not executing a PR build
if [[ "${TRAVIS_PULL_REQUEST}" = "false" ]]; then
  docker_tag="${TRAVIS_TAG:-latest}"
  if [[ "${docker_tag}" != "latest" ]]; then
    echo "### Uploading maven artifacts to bintray"
    echo
    docker build --build-arg BINTRAY_USER=${BINTRAY_USER} --build-arg BINTRAY_KEY=${BINTRAY_KEY} --build-arg APP_VERSION=${docker_tag} --target Publish .
  fi

  echo "### Pushing Docker images for tag ${docker_tag}"
  echo
  docker login -u="${DOCKERHUB_USER}" -p="${DOCKERHUB_PASS}"
  docker build --build-arg TRAVIS=${TRAVIS} --build-arg TRAVIS_JOB_ID=${TRAVIS_JOB_ID} --target Package --tag ${TRAVIS_REPO_SLUG}:${docker_tag} .
  docker login -u="${QUAYIO_USER}" -p="${QUAYIO_PASS}" quay.io
  docker build --build-arg TRAVIS=${TRAVIS} --build-arg TRAVIS_JOB_ID=${TRAVIS_JOB_ID} --target Package --tag quay.io/${TRAVIS_REPO_SLUG}:${docker_tag} .
else
  echo "### Skipping Docker publish for PR build"
  echo
fi
