# Siv3D Template Restructure Design

**Goal:** Turn this repository into a reusable Siv3D template that provides a prebuilt Siv3D base image, a fast devcontainer workflow, Linux GUI execution, and a clean path to multi-platform expansion.

## Current State

The repository is currently a proof of concept, not a template.

- `Dockerfile` builds Siv3D directly from `Siv3D/OpenSiv3D` in the image build, which makes the image expensive to rebuild and couples the game template to upstream source checkout.
- `compose.yml` can start a container with X11 access, but it only works as a manual runtime wrapper.
- `setup.sh` clones upstream `OpenSiv3D` and copies `Linux/App` into `ExampleProject/App`; this is a bootstrap helper, not a stable template mechanism.
- `ExampleProject/App` contains a copied example app and generated build artifacts, which makes the repository look like a snapshot of upstream instead of a maintainable template.
- There is no `.devcontainer/` directory.
- There is no `.github/workflows/` directory.
- There is no GHCR publishing flow.

## Target State

The repository will be split into two concerns:

1. A reusable Siv3D base image, published through GitHub Actions to GHCR.
2. A template game workspace that consumes the base image through devcontainer and compose.

The template will support these workflows:

- Open the repo in devcontainer and immediately build a game.
- Bind mount a game project directory and rebuild only the game code on iteration.
- Run graphical Linux builds with GUI forwarded to the host.
- Reuse cached Siv3D dependencies so rebuilding the template itself is fast.
- Keep the repository suitable as a GitHub template repository.

## Architecture

The core design is to move all heavy, slow, and reusable work into a published base image and leave the repository with only the project-specific layer. The base image will contain the OS dependencies, build tools, Siv3D build/install output, and cache-aware build setup. The template repository will only contain a minimal game project, devcontainer metadata, compose files for local runtime, and CI that publishes the base image.

The resulting build stack has three layers:

- **Base image layer:** Ubuntu plus compiler toolchain plus Siv3D installation.
- **Game layer:** A minimal CMake project that links against the preinstalled Siv3D package.
- **Developer wrapper layer:** devcontainer and compose definitions that mount source and build directories and forward GUI/audio to the host.

This separation makes the template cheap to iterate on because changes to game code do not invalidate the Siv3D base image. It also allows the base image to be versioned and reused by future projects.

## Repository Layout

The repository will be reorganized to make each file have one responsibility.

- `.devcontainer/devcontainer.json`: Open the template in a container built from the published Siv3D base image.
- `.devcontainer/Dockerfile`: Optional thin wrapper only if the devcontainer needs local-only adjustments; otherwise the devcontainer should consume the published base image directly.
- `docker/base/Dockerfile`: Build the Siv3D base image.
- `docker/base/entrypoint.sh` or equivalent: Optional helper for container startup, only if needed for permissions or runtime setup.
- `compose.yml`: Local runtime entry point for Linux GUI execution using the same image family as the devcontainer.
- `.github/workflows/build-base-image.yml`: Build and publish the base image to GHCR.
- `CMakeLists.txt` and/or `app/` or `game/` project files at the repository root: Minimal template game project.
- `.gitignore`: Ignore build outputs, caches, and any generated files.
- `README.md`: Explain how to use the template, how the base image works, and how to create a new game from it.

The current `ExampleProject` directory will be removed or replaced. The template should not ship with copied upstream source trees or build artifacts.

## Base Image Design

The base image is the main performance boundary.

It will contain:

- Ubuntu base OS.
- CMake, Ninja, GCC or Clang, Git, and the packages Siv3D requires on Linux.
- Siv3D source checkout pinned to a known version or commit.
- Siv3D build and install results under `/usr/local`.
- `ccache` for repeated C++ builds.
- BuildKit cache mounts for package and compiler caches where possible.

It will not contain:

- The user's game source.
- Game build outputs.
- Upstream example app content beyond what Siv3D install requires.

The base image build should be split into stages so the expensive Siv3D build is isolated from the final runtime image. The final image should be smaller than the builder stage and only keep the runtime libraries and installed Siv3D artifacts needed to compile and run a game.

## Build Caching Strategy

The design will use multiple cache boundaries:

- **Package cache:** apt cache mounts during base image build.
- **Compiler cache:** `ccache` configured in the base image and exposed to both devcontainer and compose runtime.
- **Layer cache:** copy only the files needed to build Siv3D before running the long compilation step.
- **Workspace cache:** keep game build directories outside the source tree or in a named Docker volume so game rebuilds do not reconfigure from scratch.

The build should be structured so that changes to game source do not invalidate the Siv3D layer. Changes to the base image should not require source workspace rebuilds unless compiler or ABI inputs change.

## Devcontainer Design

The devcontainer should be the default developer entry point.

It will:

- Use the published GHCR base image as the `image` or `build` source.
- Mount the repository workspace into the container.
- Mount a separate persistent cache volume for build outputs and `ccache`.
- Forward the Linux GUI environment needed for local execution.
- Provide the tools necessary to configure, build, and run the game.

The devcontainer should not rebuild Siv3D on every open. Its purpose is to reuse the published image and keep the edit-build-run loop short.

## Compose Design

`compose.yml` will remain as a local runtime path for people who prefer `docker compose` over devcontainer.

It will:

- Run the same image family as devcontainer.
- Bind mount the game workspace.
- Bind or persist a build directory.
- Forward X11 or Wayland-related host sockets as needed.
- Expose audio or input devices only if required for the game runtime.

The compose file should be a direct runtime tool, not a build script. It should not clone upstream repositories or create template content.

## GitHub Actions and GHCR

The repository will include a workflow that builds the base image and pushes it to GHCR.

The workflow should:

- Run on pushes to the default branch and on version tags if versioned publishing is desired.
- Authenticate with `GITHUB_TOKEN`.
- Build the Docker image with BuildKit enabled.
- Push the image to a package name under `ghcr.io/<owner>/<repo>` or an equivalent documented target.
- Use cache-from/cache-to so base image rebuilds are incremental in GitHub Actions as well.

The published image is the contract consumed by devcontainer and compose. The workflow must produce a stable tag strategy, such as `latest` plus a commit SHA tag or version tag.

## Template Hygiene

The repository will become a clean template repository by removing or replacing the current mock scaffolding.

Required cleanup:

- Remove copied upstream `ExampleProject` contents and generated build artifacts.
- Remove `setup.sh` if it is only a one-off bootstrap helper.
- Replace the current `README.md` with template-oriented usage instructions.
- Add a root `.gitignore` that ignores build directories, cache directories, editor junk, and container-local state.
- Keep the repository surface minimal so a new project starts with a clear structure.

The template should present a single obvious place to put game code and a single obvious command path to build and run it.

## Multi-Platform Strategy

The repository will be Linux-first but structured for future multi-platform work.

The immediate design choice is to separate:

- Platform-independent game code and CMake setup.
- Linux-specific runtime/container configuration.
- Siv3D base image contents that are only valid for Linux.

This keeps the repo aligned with future expansion similar to `Siv3DCMake` without trying to implement every target now. A later extension can add platform-specific presets, toolchains, or alternate images without rewriting the template contract.

## Testing and Verification

The finished work will be validated with the following checks:

- Build the base image successfully.
- Confirm the published image is usable as a devcontainer base.
- Open the template in a container and configure the sample game.
- Build the game in the container.
- Run the game with GUI forwarding on Linux.
- Rebuild after a small source change and confirm only the game layer recompiles.
- Confirm the repo no longer contains generated build artifacts or mock bootstrap content.

## Migration Plan

The change will be implemented in stages:

1. Introduce the base image build and GHCR publish workflow.
2. Replace the current `ExampleProject` mock with a real template project layout.
3. Add devcontainer metadata that consumes the published image.
4. Update compose to match the new runtime contract.
5. Rewrite documentation and ignore rules.
6. Remove the old bootstrap helper if it is no longer necessary.

## Non-Goals

This redesign will not:

- Implement a full cross-platform build farm.
- Recreate the entire upstream Siv3D example repository in this template.
- Guarantee support for every host graphics stack beyond Linux GUI forwarding that is explicitly configured.
- Add game-specific features beyond the template and build infrastructure.

