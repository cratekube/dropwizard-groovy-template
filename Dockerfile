FROM openjdk:8u131-jdk-alpine as BUILD

ARG TRAVIS
ARG TRAVIS_JOB_ID

WORKDIR /app
RUN apk --no-cache add libstdc++

COPY gradle/wrapper ./gradle/wrapper
COPY gradlew ./
RUN ./gradlew --version

COPY *gradle* ./

# Build the application fat jar, invalidate only if the source changes
COPY src/main ./src/main
RUN ./gradlew shadowJar

COPY swagger-config.json settings.gradle ./
RUN ./gradlew buildClient

COPY src/test ./src/test
RUN ./gradlew test

COPY codenarc.rules ./
RUN ./gradlew check

RUN ./gradlew jacocoTestReport coveralls