#!/usr/bin/env bash
set -xeuo pipefail

BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"

printf "::group:: ===Final Image Cleanup===\n"
bash "${BUILD_SCRIPTS_PATH}/cleanup.sh"
printf "::endgroup::\n"
