FROM ubuntu:22.04 AS builder

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apt-get update && apt-get install -y sudo

ARG USERNAME=user
ARG GROUPNAME=user
ARG UID=1000
ARG GID=1001
ARG PASSWORD=user
RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID -G sudo $USERNAME && \
    echo $USERNAME:$PASSWORD | chpasswd && \
    echo "$USERNAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME/

RUN sudo chmod -R 700 /var/cache/apt/archives/partial/
RUN sudo chown -R _apt:root /var/cache/apt/archives/partial/
RUN sudo apt update -y && sudo apt upgrade -y

RUN sudo apt install -y \
    git \
    cmake \
    gcc \
    g++ \
    ninja-build \
    libasound2-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libboost-dev \
    libcurl4-openssl-dev \
    libgtk-3-dev \
    libgif-dev \
    libglu1-mesa-dev \
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
    uuid-dev \
    xorg-dev

RUN mkdir /home/$USERNAME/OpenSiv3D
RUN git clone https://github.com/Siv3D/OpenSiv3D.git /home/$USERNAME/OpenSiv3D

RUN mkdir /home/$USERNAME/OpenSiv3D/Linux/build
WORKDIR /home/$USERNAME/OpenSiv3D/Linux/build
RUN cmake -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
WORKDIR /home/$USERNAME/OpenSiv3D/Linux
RUN cmake --build build

WORKDIR /home/$USERNAME/OpenSiv3D/Linux
RUN sudo cmake --install build

FROM ubuntu:22.04

RUN ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apt-get update && apt-get install -y sudo

ARG USERNAME=user
ARG GROUPNAME=user
ARG UID=1000
ARG GID=1001
ARG PASSWORD=user
RUN groupadd -g $GID $GROUPNAME && \
    useradd -m -s /bin/bash -u $UID -g $GID -G sudo $USERNAME && \
    echo $USERNAME:$PASSWORD | chpasswd && \
    echo "$USERNAME   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER $USERNAME
WORKDIR /home/$USERNAME/

RUN sudo chmod -R 700 /var/cache/apt/archives/partial/
RUN sudo chown -R _apt:root /var/cache/apt/archives/partial/
RUN sudo apt update -y && sudo apt upgrade -y

RUN sudo apt install -y \
    git \
    cmake \
    gcc \
    g++ \
    ninja-build \
    libasound2-dev \
    libavcodec-dev \
    libavformat-dev \
    libavutil-dev \
    libboost-dev \
    libcurl4-openssl-dev \
    libgtk-3-dev \
    libgif-dev \
    libglu1-mesa-dev \
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
    uuid-dev \
    xorg-dev

COPY --from=builder --chown=root:root /usr/local/include/Siv3D/ /usr/local/include/Siv3D/
COPY --from=builder --chown=root:root /usr/local/lib/libSiv3D.a /usr/local/lib/libSiv3D.a
COPY --from=builder --chown=root:root /usr/local/lib/cmake/Siv3D/Siv3DConfig.cmake /usr/local/lib/cmake/Siv3D/Siv3DConfig.cmake
