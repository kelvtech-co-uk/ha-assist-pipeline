#!/bin/sh
set -eo pipefail # Exit immediately if a command exits with a non-zero status

/bin/sh -c "/wyoming-whisper-api-client/script/run --uri tcp://0.0.0.0:7891 \
    --api http://${WHISPER_CPP_HOSTNAME}:${WHISPER_CPP_PORT}/inference"