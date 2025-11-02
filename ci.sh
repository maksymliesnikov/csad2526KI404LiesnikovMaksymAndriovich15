#!/usr/bin/env bash
set -euo pipefail

# ci.sh - POSIX / macOS / Linux CI helper
# Steps:
#  - create build directory
#  - enter build
#  - configure with CMake
#  - build
#  - run tests with CTest

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "==> Creating build directory"
mkdir -p build
cd build

echo "==> Configuring project with CMake"
cmake ..

echo "==> Building project"
cmake --build . --config Release

echo "==> Running tests (CTEST)"
ctest --output-on-failure -C Release

echo "==> ci.sh finished"

