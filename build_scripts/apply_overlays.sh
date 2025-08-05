#!/usr/bin/env bash
set -xeuo pipefail

CONTEXT_PATH="$(realpath "$(dirname "$0")/..")" # should return /run/context
BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"
MAJOR_VERSION_NUMBER="$(sh -c '. /usr/lib/os-release ; echo ${VERSION_ID%.*}')"
SCRIPTS_PATH="$(realpath "$(dirname "$0")/scripts")"
export SCRIPTS_PATH
export MAJOR_VERSION_NUMBER

copy_systemfiles_for() {
    WHAT=$1
    shift
    DISPLAY_NAME=$WHAT
    if [ "${CUSTOM_NAME}" != "" ]; then
        DISPLAY_NAME=$CUSTOM_NAME
    fi
    printf "::group:: ===%s-file-copying===\n" "${DISPLAY_NAME}"
    if [ -d "${CONTEXT_PATH}/overrides/$WHAT" ]; then
        cp -avf "${CONTEXT_PATH}/overrides/$WHAT/." /
    fi
    printf "::endgroup::\n"
}

run_overlayscripts_for() {
    WHAT=$1
    shift
    find "${BUILD_SCRIPTS_PATH}/overrides/$WHAT" -maxdepth 1 -iname "[49][0-9]-*.sh" -type f -print0 | sort --zero-terminated --sort=human-numeric | while IFS= read -r -d $'\0' script ; do
        if [ "${CUSTOM_NAME}" != "" ]; then
            WHAT=$CUSTOM_NAME
        fi
        printf "::group:: ===$WHAT-%s===\n" "$(basename "$script")"
        bash "$(realpath "$script")"
        printf "::endgroup::\n"
    done
}

CUSTOM_NAME="base"
copy_systemfiles_for ../files
run_overlayscripts_for ..
CUSTOM_NAME=""

copy_systemfiles_for "$(arch)"
run_overlayscripts_for "$(arch)"

if [ "$ENABLE_DX" == "1" ]; then
    copy_systemfiles_for dx
    run_overlayscripts_for dx
    copy_systemfiles_for "$(arch)-dx"
    run_overlayscripts_for "$(arch)/dx"
fi

if [ "$ENABLE_GDX" == "1" ]; then
    copy_systemfiles_for gdx
    run_overlayscripts_for gdx
    copy_systemfiles_for "$(arch)-gdx"
    run_overlayscripts_for "$(arch)/gdx"
fi
