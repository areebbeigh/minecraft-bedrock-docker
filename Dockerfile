ARG TARGETPLATFORM=linux/amd64
FROM --platform=$TARGETPLATFORM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    bash \
    ca-certificates \
    libcurl4 \
    libgcc-s1 \
    libssl3 \
    libstdc++6 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /bedrock_server
COPY . /bedrock_server

EXPOSE 19132/udp 19133/udp
ENV LD_LIBRARY_PATH=.

RUN chmod +x /bedrock_server/docker-entrypoint.sh \
  && ln -sf /bedrock_server/docker-entrypoint.sh /usr/local/bin/bedrock-entrypoint

ENTRYPOINT ["bedrock-entrypoint"]
CMD ["./bedrock_server"]
