#!/usr/bin/env bash

set -xeuo pipefail

# This script is used to install packages and copy system files during the build process.
CONTEXT_PATH="$(realpath "$(dirname "$0")/..")" # should return /run/context
BUILD_SCRIPTS_PATH="$(realpath "$(dirname "$0")")"
MAJOR_VERSION_NUMBER="$(sh -c '. /usr/lib/os-release ; echo ${VERSION_ID%.*}')"
SCRIPTS_PATH="$(realpath "$(dirname "$0")/scripts")"
export SCRIPTS_PATH
export MAJOR_VERSION_NUMBER

run_packagescripts_for() {
    WHAT=$1
    shift
    find "${BUILD_SCRIPTS_PATH}/overrides/$WHAT" -maxdepth 1 -iname "[12][0-9]-*.sh" -type f -print0 | sort --zero-terminated --sort=human-numeric | while IFS= read -r -d $'\0' script ; do
        if [ "${CUSTOM_NAME}" != "" ]; then
            WHAT=$CUSTOM_NAME
        fi
        printf "::group:: ===$WHAT-%s===\n" "$(basename "$script")"
        bash "$(realpath "$script")"
        printf "::endgroup::\n"
    done
}

copy_systemfiles_for() {
	WHAT=$1
	shift
	DISPLAY_NAME=$WHAT
	if [ "${CUSTOM_NAME}" != "" ] ; then
		DISPLAY_NAME=$CUSTOM_NAME
	fi
	printf "::group:: ===%s-file-copying===\n" "${DISPLAY_NAME}"
	cp -avf "${CONTEXT_PATH}/overrides/$WHAT/." /
	printf "::endgroup::\n"
}

CUSTOM_NAME="base"
copy_systemfiles_for ../files
run_packagescripts_for ..
CUSTOM_NAME=""

copy_systemfiles_for "$(arch)"
run_packagescripts_for "$(arch)"

if [ "$ENABLE_DX" == "1" ]; then
    copy_systemfiles_for dx
    run_packagescripts_for dx
    copy_systemfiles_for "$(arch)-dx"
    run_packagescripts_for "$(arch)/dx"
fi

if [ "$ENABLE_GDX" == "1" ]; then
    copy_systemfiles_for gdx
    run_packagescripts_for gdx
    copy_systemfiles_for "$(arch)-gdx"
    run_packagescripts_for "$(arch)/gdx"
fi
