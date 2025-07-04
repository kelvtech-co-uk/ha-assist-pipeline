#!/bin/bash
set -eo pipefail # Exit immediately if a command exits with a non-zero status

/bin/bash -c "/whisper.cpp/whisper-server -l ${WHISPER_LANG} \
    -bs ${WHISPER_BEAM_SIZE} \
    -m /models/ggml-${WHISPER_MODEL}.bin \
    --host 0.0.0.0 \
    --port 8910 \
    --suppress-nst \
    --prompt \"${WHISPER_PROMPT}\" \
    --ov-e-device GPU"