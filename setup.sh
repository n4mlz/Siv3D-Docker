#!/bin/bash

set -e

REPO_URL="https://github.com/Siv3D/OpenSiv3D.git"
TEMP_DIR=$(mktemp -d)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${SCRIPT_DIR}/ExampleProject/App"
SOURCE_DIR="${TEMP_DIR}/Linux/App"

echo "Cloning OpenSiv3D repository..."
git clone --depth 1 "${REPO_URL}" "${TEMP_DIR}"

if [ ! -d "${SOURCE_DIR}" ]; then
    echo "Error: ${SOURCE_DIR} not found" >&2
    rm -rf "${TEMP_DIR}"
    exit 1
fi

echo "Creating ExampleProject/App directory..."
mkdir -p "${TARGET_DIR}"

echo "Copying contents from Linux/App..."
cp -r "${SOURCE_DIR}"/* "${TARGET_DIR}/"

echo "Cleaning up temporary directory..."
rm -rf "${TEMP_DIR}"

echo "Done: ${TARGET_DIR}"
