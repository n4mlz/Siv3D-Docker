## Siv3D Template

This repository is a Linux-first Siv3D template built around a reusable base image.

### What it gives you

- A root-level CMake project for your game code
- A published Siv3D base image at `ghcr.io/n4mlz/siv3d-docker-base`
- A devcontainer that reuses that image instead of rebuilding Siv3D on open
- A `docker compose` path for Linux GUI development with host display forwarding

### Local development

Open the repository in devcontainer or start the compose service:

```bash
docker compose up -d
docker compose exec siv3d-app bash
```

Build the template game from the repository root:

```bash
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
```

Run the smoke test binary:

```bash
./build/Siv3DTemplate
```

### GitHub Actions

The base image is built from `docker/base/Dockerfile` and published to GHCR by `.github/workflows/publish-base-image.yml`.

The workflow publishes `latest` and commit/tag-based image tags so the devcontainer and compose setup can stay fast and reproducible.

### Project layout

- `CMakeLists.txt`: root template project
- `src/Main.cpp`: graphical smoke test
- `docker/base/Dockerfile`: Siv3D base image build
- `.devcontainer/devcontainer.json`: containerized editor setup
- `compose.yml`: local runtime entrypoint
