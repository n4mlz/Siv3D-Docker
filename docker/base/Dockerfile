# syntax=docker/dockerfile:1.7

FROM ubuntu:22.04 AS build

ARG DEBIAN_FRONTEND=noninteractive
ARG SIV3D_REF=v0.6.16
ARG USERNAME=user
ARG UID=1000
ARG GID=1000

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        ccache \
        cmake \
        g++ \
        gcc \
        git \
        libasound2-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libboost-dev \
        libcurl4-openssl-dev \
        libgif-dev \
        libglu1-mesa-dev \
        libgtk-3-dev \
        libharfbuzz-dev \
        libmpg123-dev \
        libopencv-dev \
        libopus-dev \
        libopusfile-dev \
        libsoundtouch-dev \
        libswresample-dev \
        libtiff-dev \
        libturbojpeg0-dev \
        libvorbis-dev \
        libwebp-dev \
        libxft-dev \
        ninja-build \
        uuid-dev \
        xorg-dev && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g "${GID}" "${USERNAME}" && \
    useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"

ENV CMAKE_C_COMPILER_LAUNCHER=ccache \
    CMAKE_CXX_COMPILER_LAUNCHER=ccache \
    CCACHE_DIR=/cache/ccache

RUN mkdir -p /cache/ccache && chown -R "${USERNAME}:${USERNAME}" /cache

WORKDIR /tmp
RUN git clone --depth 1 --branch "${SIV3D_REF}" https://github.com/Siv3D/OpenSiv3D.git /tmp/OpenSiv3D
RUN cmake -S /tmp/OpenSiv3D/Linux -B /tmp/OpenSiv3D/Linux/build -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo
RUN --mount=type=cache,target=/cache/ccache \
    cmake --build /tmp/OpenSiv3D/Linux/build
RUN cmake --install /tmp/OpenSiv3D/Linux/build

FROM ubuntu:22.04 AS final

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=user
ARG UID=1000
ARG GID=1000

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        ccache \
        cmake \
        g++ \
        gcc \
        git \
        libasound2-dev \
        libavcodec-dev \
        libavformat-dev \
        libavutil-dev \
        libboost-dev \
        libcurl4-openssl-dev \
        libgif-dev \
        libglu1-mesa-dev \
        libgtk-3-dev \
        libharfbuzz-dev \
        libmpg123-dev \
        libopencv-dev \
        libopus-dev \
        libopusfile-dev \
        libsoundtouch-dev \
        libswresample-dev \
        libtiff-dev \
        libturbojpeg0-dev \
        libvorbis-dev \
        libwebp-dev \
        libxft-dev \
        ninja-build \
        uuid-dev \
        xorg-dev && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g "${GID}" "${USERNAME}" && \
    useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"

COPY --from=build /usr/local /usr/local

ENV CCACHE_DIR=/cache/ccache
RUN mkdir -p /cache/ccache && chown -R "${USERNAME}:${USERNAME}" /cache
