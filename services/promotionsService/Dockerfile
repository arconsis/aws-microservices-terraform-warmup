####
# This Dockerfile is used in order to build a container that runs the Quarkus application in JVM mode
#
# Build the image with:
#
# docker build -f Dockerfile.fast-jar -t hero-threeswipes-gw .
#
# Run the container using:
#
# docker run -i --rm -p 8080:8080 hero-threeswipes-gw
#
# If you want to include the debug port into your docker image
# you will have to expose the debug port (default 5005) like this:  EXPOSE 8080 5050
#
# Then run the container using:
#
# docker run -i --rm -p 8080:8080 -p 5005:5005 -e JAVA_ENABLE_DEBUG="true" hero-threeswipes-gw
#
###

## Stage 1 : build with gradle
FROM quay.io/quarkus/centos-quarkus-maven:21.1.0-java11 AS build
COPY src /usr/src/app/src
COPY build.gradle.kts /usr/src/app
COPY settings.gradle.kts /usr/src/app
COPY gradle.properties /usr/src/app
USER root
RUN chown -R quarkus /usr/src/app
USER quarkus
RUN gradle -b /usr/src/app/build.gradle.kts clean quarkusBuild


## Stage 2 : create the docker final image
FROM registry.access.redhat.com/ubi8/ubi-minimal:8.3

ARG JAVA_PACKAGE=java-11-openjdk-headless
ARG RUN_JAVA_VERSION=1.3.8

ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en'

# Install java and the run-java script
# Also set up permissions for user `1001`
RUN microdnf install curl ca-certificates ${JAVA_PACKAGE} \
    && microdnf update \
    && microdnf clean all \
    && mkdir /deployments \
    && chown 1001 /deployments \
    && chmod "g+rwX" /deployments \
    && chown 1001:root /deployments \
    && curl https://repo1.maven.org/maven2/io/fabric8/run-java-sh/${RUN_JAVA_VERSION}/run-java-sh-${RUN_JAVA_VERSION}-sh.sh -o /deployments/run-java.sh \
    && chown 1001 /deployments/run-java.sh \
    && chmod 540 /deployments/run-java.sh \
    && echo "securerandom.source=file:/dev/urandom" >> /etc/alternatives/jre/lib/security/java.security

# Configure the JAVA_OPTIONS, you can add -XshowSettings:vm to also display the heap size.
ENV JAVA_OPTIONS="-Dquarkus.http.host=0.0.0.0 -Djava.util.logging.manager=org.jboss.logmanager.LogManager"

# We make four distinct layers so if there are application changes the library layers can be re-used
COPY --chown=1001 --from=build /usr/src/app/build/quarkus-app/lib/ /deployments/lib/
COPY --chown=1001 --from=build /usr/src/app/build/quarkus-app/*.jar /deployments/
COPY --chown=1001 --from=build /usr/src/app/build/quarkus-app/app/ /deployments/app/
COPY --chown=1001 --from=build /usr/src/app/build/quarkus-app/quarkus/ /deployments/quarkus/

EXPOSE 8080
USER 1001

ENTRYPOINT [ "/deployments/run-java.sh" ]
