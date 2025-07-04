FROM python:3-alpine3.22

SHELL ["/bin/sh", "-o", "pipefail", "-c"]

RUN apk update && apk add --no-cache \
    git \
    netcat-openbsd

RUN git clone https://github.com/ser/wyoming-whisper-api-client.git wyoming-whisper-api-client \
    && cd wyoming-whisper-api-client \
    && script/setup

WORKDIR /wyoming-whisper-api-client

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 7891 \
        | grep -iq "whisper-cpp" \
        || exit 1