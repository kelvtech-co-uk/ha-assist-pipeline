FROM ubuntu:24.04 AS builder

ARG WHISPER_MODEL
ARG WHISPER_CPP_VERSION
ARG OPENVINO_TGZ
ARG OPENVINO_DIR_NAME
ARG OPENVINO_URL

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    netcat-traditional \
    ca-certificates \
    build-essential \
    cmake \
    git \
    intel-opencl-icd \
    python3 \
    python3-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN update-ca-certificates

WORKDIR /opt

RUN git clone https://github.com/ggerganov/whisper.cpp.git whisper.cpp \
    && cd whisper.cpp \
    && git reset --hard v${WHISPER_CPP_VERSION} \
    && cd models \
    && python3 -m venv openvino_conv_env \
    && source openvino_conv_env/bin/activate \
    && python -m pip install --upgrade pip \
    && pip install -r requirements-openvino.txt \
    && ./download-ggml-model.sh ${WHISPER_MODEL} \
    && python3 convert-whisper-to-openvino.py --model ${WHISPER_MODEL} \
    && deactivate

RUN wget -q ${OPENVINO_URL} -O ${OPENVINO_TGZ} \
    && tar -xf ${OPENVINO_TGZ} \
    && rm ${OPENVINO_TGZ} \
    && mkdir intel \
    && mv ${OPENVINO_DIR_NAME}/ intel/openvino \
    && source /opt/intel/openvino/setupvars.sh \
    && cd /opt/whisper.cpp \
    && cmake -B build -DWHISPER_OPENVINO=1 -DOPENVINO_DIR=/opt/intel/openvino \
    && cmake --build build -j --config Release

# 2nd Stage
FROM ubuntu:24.04 AS runner

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    netcat-traditional \
    intel-opencl-icd \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Copy prepared models from builder into runner/final stage
WORKDIR /models
COPY --from=builder /opt/whisper.cpp/models/ggml-${WHISPER_MODEL}* /models/

# Copy OpenVino runtime from builder into runner/final stage and update library path env
WORKDIR /opt/intel/openvino/runtime
COPY --from=builder /opt/intel/openvino/runtime /opt/intel/openvino/runtime
ENV LD_LIBRARY_PATH=/opt/intel/openvino/runtime/lib/intel64:/usr/local/lib:$LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=/opt/intel/openvino/runtime/3rdparty/tbb/lib:$LD_LIBRARY_PATH

# Copy ggml & whisper.cpp binaries & source libraries from builder into runner/final stage and update library path env
WORKDIR /whisper.cpp
COPY --from=builder /opt/whisper.cpp/build/src/* src/
ENV LD_LIBRARY_PATH=/whisper.cpp/src:$LD_LIBRARY_PATH
COPY --from=builder /opt/whisper.cpp/build/ggml/* ggml/
ENV LD_LIBRARY_PATH=/whisper.cpp/ggml:$LD_LIBRARY_PATH
COPY --from=builder /opt/whisper.cpp/build/bin/* .

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

HEALTHCHECK --start-period=10m \
    CMD echo '{ "type": "describe" }' \
        | nc -w 1 localhost 8910 \
        | grep -iq "whisper.cpp" \
        || exit 1