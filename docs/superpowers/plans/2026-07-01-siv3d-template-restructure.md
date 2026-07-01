# Siv3D Template Restructure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Convert the repository into a clean Siv3D template with a published base image, fast local iteration, Linux GUI execution, and a GitHub Actions publish pipeline.

**Architecture:** Split the repo into a reusable base-image layer and a lightweight game template layer. The base image owns the expensive Siv3D build, toolchain, and caches. The repo root owns only the template game, container entrypoints, and CI that publishes the base image to GHCR.

**Tech Stack:** Docker BuildKit, Ubuntu 22.04, CMake, Ninja, GCC, ccache, devcontainer, Docker Compose, GitHub Actions, GHCR, Siv3D/OpenSiv3D.

---

### Task 1: Replace the mock template with a real minimal game project

**Files:**
- Delete: `ExampleProject/`
- Delete: `setup.sh`
- Delete: `Dockerfile`
- Delete: `screenshot.png`
- Create: `.gitignore`
- Create: `CMakeLists.txt`
- Create: `src/Main.cpp`
- Modify: `README.md`

- [ ] **Step 1: Remove the copied upstream tree and bootstrap helper**

Run:

```bash
git rm -r ExampleProject
git rm setup.sh Dockerfile screenshot.png
```

Expected: only the template root remains, with no copied `OpenSiv3D` example tree and no generated `build/` artifacts.

- [ ] **Step 2: Add a minimal template project**

Create a root `CMakeLists.txt` that links against the installed Siv3D package and builds one executable from `src/Main.cpp`:

```cmake
cmake_minimum_required(VERSION 3.20)
project(Siv3DTemplate CXX)

find_package(Siv3D REQUIRED)

add_executable(Siv3DTemplate
    src/Main.cpp
)

target_link_libraries(Siv3DTemplate PRIVATE Siv3D::Siv3D)
target_compile_features(Siv3DTemplate PRIVATE cxx_std_20)
```

Create `src/Main.cpp` as a small graphical smoke test, not the current headless mock:

```cpp
#include <Siv3D.hpp>

void Main()
{
    Scene::SetBackground(ColorF{ 0.16, 0.18, 0.22 });

    const Font font{ 28 };

    while (System::Update())
    {
        font(U"Siv3D template").draw(40, 40, Palette::White);
        font(U"Edit src/Main.cpp and rebuild").draw(40, 84, Palette::Skyblue);
    }
}
```

- [ ] **Step 3: Add repository ignore rules**

Create `.gitignore` with the actual outputs we want to exclude:

```gitignore
build/
**/build/
cmake-build-*/
.cache/
.ccache/
.devcontainer/.cache/
*.user
*.log
.DS_Store
```

- [ ] **Step 4: Rewrite the README for template usage**

Update `README.md` to explain only the real workflows:

```md
1. Open in devcontainer or run `docker compose up`.
2. Configure and build the template game from the repo root.
3. Run the binary with Linux GUI forwarding.
4. Publish the base image through GitHub Actions.
```

Run:

```bash
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

Expected: the template builds against the eventual base image without needing any bootstrap helper.

---

### Task 2: Build the reusable Siv3D base image with cache-friendly layering

**Files:**
- Create: `docker/base/Dockerfile`
- Create: `.dockerignore`
- Modify: `README.md`

- [ ] **Step 1: Move the current container build logic into a dedicated base-image Dockerfile**

Create `docker/base/Dockerfile` as a multi-stage build. The build stage installs the Siv3D dependencies, clones `Siv3D/OpenSiv3D` at the pinned `v0.6.16` release tag, and builds/install it. The final stage keeps the installed Siv3D artifacts and the same Linux development packages needed to compile and run games, but not the upstream source tree or build tree.

Use BuildKit syntax and cache mounts:

```dockerfile
# syntax=docker/dockerfile:1.7
FROM ubuntu:22.04 AS build

ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt \
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
        xorg-dev

ARG USERNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g "${GID}" "${USERNAME}" && useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"
ENV CMAKE_CXX_COMPILER_LAUNCHER=ccache

ARG SIV3D_REF=v0.6.16
RUN git clone --depth 1 --branch "${SIV3D_REF}" https://github.com/Siv3D/OpenSiv3D.git /tmp/OpenSiv3D
RUN cmake -S /tmp/OpenSiv3D/Linux -B /tmp/OpenSiv3D/Linux/build -GNinja -DCMAKE_BUILD_TYPE=RelWithDebInfo
RUN cmake --build /tmp/OpenSiv3D/Linux/build
RUN cmake --install /tmp/OpenSiv3D/Linux/build

FROM ubuntu:22.04
RUN apt-get update && apt-get install -y --no-install-recommends \
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
        xorg-dev && rm -rf /var/lib/apt/lists/*
COPY --from=build /usr/local /usr/local
ARG USERNAME=user
ARG UID=1000
ARG GID=1000
RUN groupadd -g "${GID}" "${USERNAME}" && useradd -m -u "${UID}" -g "${GID}" -s /bin/bash "${USERNAME}"
ENV CCACHE_DIR=/cache/ccache
RUN mkdir -p /cache/ccache && chown -R "${USERNAME}:${USERNAME}" /cache
```

Keep the final stage small by cleaning apt lists and not carrying build sources into it.

- [ ] **Step 2: Add ignore rules for Docker builds**

Create `.dockerignore` so container builds do not ship the repo history, build outputs, or old mock assets into the build context:

```dockerignore
.git
build
**/build
ExampleProject
docs/superpowers/plans
docs/superpowers/specs
screenshot.png
```

- [ ] **Step 3: Make the base image cache-aware**

Inside the Dockerfile, configure `ccache` as the compiler launcher and preserve its cache directory at a stable path such as `/cache/ccache`. Keep the Siv3D build inputs ordered so changes to the repository root do not invalidate the long Siv3D build layer.

Run:

```bash
docker buildx build -f docker/base/Dockerfile --load .
```

Expected: the base image builds locally and can be reused by later tasks.

---

### Task 3: Add devcontainer and compose support on top of the published base image

**Files:**
- Create: `.devcontainer/devcontainer.json`
- Modify: `compose.yml`
- Modify: `README.md`

- [ ] **Step 1: Make the compose file the runtime contract**

Rewrite `compose.yml` so the service runs from the published base image, bind-mounts the repo root into the container, and keeps build output in a named volume instead of inside the source tree.

Target shape:

```yaml
services:
  siv3d-app:
    image: ghcr.io/xlair-dev/siv3d-docker-base:latest
    container_name: siv3d-app
    user: user
    stdin_open: true
    tty: true
    working_dir: /workspace
    volumes:
      - ./:/workspace
      - siv3d-build:/workspace/build
      - siv3d-ccache:/cache/ccache
      - /tmp/.X11-unix:/tmp/.X11-unix:rw
    environment:
      DISPLAY: ${DISPLAY}
      XDG_RUNTIME_DIR: ${XDG_RUNTIME_DIR}
      PULSE_SERVER: ${PULSE_SERVER}
volumes:
  siv3d-build:
  siv3d-ccache:
```

Keep Linux GUI forwarding explicit and documented. Do not reintroduce the old `ExampleProject` bind mount.

- [ ] **Step 2: Make devcontainer reuse the same container image**

Create `.devcontainer/devcontainer.json` that points at the compose service instead of building Siv3D again inside the devcontainer:

```json
{
  "name": "Siv3D Template",
  "dockerComposeFile": ["../compose.yml"],
  "service": "siv3d-app",
  "workspaceFolder": "/workspace",
  "shutdownAction": "stopCompose",
  "remoteUser": "user"
}
```

Use the same image path in compose and devcontainer so the devcontainer is just a developer wrapper around the published base image. The published image path is `ghcr.io/xlair-dev/siv3d-docker-base:latest`.

- [ ] **Step 3: Document the container workflow**

Update the README with the actual commands:

```bash
docker compose up -d
docker compose exec siv3d-app bash
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
./build/Siv3DTemplate
```

Expected: a fresh checkout can be opened in devcontainer or via compose without any bootstrap script.

---

### Task 4: Publish the base image from GitHub Actions

**Files:**
- Create: `.github/workflows/publish-base-image.yml`
- Modify: `README.md`

- [ ] **Step 1: Add a workflow that builds and pushes the base image**

Create a workflow that runs on push to `main`, tag pushes, and manual dispatch. Use `docker/login-action`, `docker/metadata-action`, and `docker/build-push-action`.

Target structure:

```yaml
name: publish-base-image

on:
  push:
    branches: [main]
    tags: ["v*"]
  workflow_dispatch:

permissions:
  contents: read
  packages: write

jobs:
  build-and-publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/metadata-action@v5
        id: meta
        with:
          images: ghcr.io/xlair-dev/siv3d-docker-base
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v6
        with:
          context: .
          file: docker/base/Dockerfile
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

Tag the image as `latest` and the commit SHA so devcontainer and compose have a stable pull target and a reproducible fallback. The package name should be `ghcr.io/xlair-dev/siv3d-docker-base`.

- [ ] **Step 2: Keep the package name and image tag strategy documented**

Update `README.md` so the published GHCR image is part of the template contract. Document which tag is considered the default and how the workflow tags releases.

- [ ] **Step 3: Validate the workflow locally as far as possible**

Run:

```bash
docker buildx build -f docker/base/Dockerfile --load .
```

Expected: the Dockerfile used by GitHub Actions is valid before the workflow runs in CI.

---

### Task 5: Remove obsolete mock paths and verify the template surface is clean

**Files:**
- Modify: `README.md`
- Modify: `.gitignore`

- [ ] **Step 1: Remove obsolete references**

Search the tree for mock-era markers and delete or rewrite them:

```bash
rg -n "ExampleProject|setup.sh|OpenSiv3D/Linux/App|Siv3DTest" .
```

Expected: only intentional mentions remain in documentation where they describe the migration history.

- [ ] **Step 2: Re-run the template smoke build**

Run the template build from the repository root with the new project layout:

```bash
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

Expected: the template project builds cleanly against the installed Siv3D package from the base image.

- [ ] **Step 3: Confirm the container path**

Run:

```bash
docker compose up -d
docker compose exec siv3d-app bash
```

Then inside the container:

```bash
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

Expected: the same code path works both in compose and in devcontainer.

- [ ] **Step 4: Commit the finished template state**

Commit the cleanup together with the new template and container files so the repository lands on a coherent template snapshot.
