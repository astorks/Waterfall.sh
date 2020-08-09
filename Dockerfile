FROM ubuntu:20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    jq \
    openjdk-11-jre \
  && rm -rf /var/lib/apt/lists/*

COPY ./waterfall.sh /usr/local/bin

RUN chmod +x /usr/local/bin/waterfall.sh

RUN useradd --create-home --shell /bin/bash minecraft \
 && mkdir -p /opt/waterfall /var/opt/waterfall \
 && chown -R minecraft /var/opt/waterfall/

USER minecraft
WORKDIR /var/opt/waterfall
VOLUME /var/opt/waterfall
EXPOSE 25565

ENV WATERFALL_VERSION="1.16"
ENV WATERFALL_JAR_NAME="waterfall.jar"
ENV WATERFALL_START_MEMORY="512M"
ENV WATERFALL_MAX_MEMORY="512M"
ENV WATERFALL_UPDATE_SECONDS=86400

ENTRYPOINT [ "waterfall.sh" ]