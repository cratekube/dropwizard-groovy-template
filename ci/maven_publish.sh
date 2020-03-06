#!/bin/bash

set -o nounset
set -o errexit

gradleCommand=$([[ -z "${TRAVIS_TAG+x}" ]] && echo "artifactoryPublish" || echo "bintrayUpload")

## check for required environment vars
missingVars=()
[[ -z "${JFROG_DEPLOY_USER+x}" ]] && missingVars+=(JFROG_DEPLOY_USER)
[[ -z "${JFROG_DEPLOY_KEY+x}" ]] && missingVars+=(JFROG_DEPLOY_KEY)
if [[ ! -z "${TRAVIS_TAG+x}" ]]; then
  [[ -z "${BINTRAY_PUBLISH}" ]] && missingVars+=(BINTRAY_PUBLISH)
  [[ -z "${APP_VERSION}" ]] && missingVars+=(APP_VERSION)
fi

## exit early if env vars are missing
if [[ "${#missingVars[@]}" > 0 ]]; then
  echo "Executing [${gradleCommand}] requires the environment vars [${missingVars[@]}]"
  exitStatus=$([[ -z "${TRAVIS_TAG+x}" ]] && echo 0 || echo 1)
  exit ${exitStatus}
fi

## if we have the required env vars, run gradlew command
./gradlew --no-daemon ${gradleCommand}
