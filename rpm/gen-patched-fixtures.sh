#!/usr/bin/env bash
#
# WARNING: Calling this script by hand is not recommended. It should instead be
# called by the pulp-fixtures make file. That's because this script doesn't
# perform the same human-friendly input validation as `./gen-fixtures.sh`, and
# it includes hard-coded relative paths.
#
# Usage:
#
#     gen-patched-assets.sh <output_dir> <updateinfo_patch>
#
# Behaviour:
#
# 1. Create a temporary directory.
# 2. Copy assets into this directory.
# 3. Apply a patch to assets_dir/updateinfo.xml.
# 4. Call gen-fixtures.sh, and point it at our patched assets.
# 5. Remove the temporary directory.
#
set -euo pipefail

# Read arguments.
output_dir="${1}"
updateinfo_patch=$(realpath "${2}")

# Define a procedure for graceful termination.
cleanup() {
    if [ -n "${assets_dir:-}" ]; then
        rm -rf "${assets_dir}"
    fi
}
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM

# Generate patched assets.
assets_dir="$(mktemp --directory)"
cp -rt "${assets_dir}" rpm/assets/*
patch "${assets_dir}/updateinfo.xml" "${updateinfo_patch}"
./rpm/gen-fixtures.sh "${output_dir}" "${assets_dir}"
