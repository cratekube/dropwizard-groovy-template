FROM openjdk:8u131-jdk-alpine as BUILD

## build args required for coveralls reporting
ARG TRAVIS
ARG TRAVIS_JOB_ID

WORKDIR /app
RUN apk --no-cache add libstdc++

COPY gradle/wrapper ./gradle/wrapper
COPY gradlew ./
RUN ./gradlew --no-daemon --version

COPY *gradle* ./
COPY gradle/*.gradle ./gradle/
COPY .git ./.git/

# Build the application fat jar, invalidate only if the source changes
COPY src/main ./src/main
RUN ./gradlew --no-daemon shadowJar

COPY swagger-config.json ./
RUN ./gradlew --no-daemon buildClient

COPY src/test ./src/test
RUN ./gradlew --no-daemon test

COPY codenarc.groovy ./
RUN ./gradlew --no-daemon check

RUN ./gradlew --no-daemon jacocoTestReport coveralls