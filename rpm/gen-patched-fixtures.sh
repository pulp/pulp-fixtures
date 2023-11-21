#!/usr/bin/env bash
# coding=utf-8
#
# WARNING: Calling this script by hand is not recommended. It should instead be
# called by the pulp-fixtures make file. That's because this script doesn't
# perform the same human-friendly input validation as `./gen-fixtures.sh`, and
# it includes hard-coded relative paths.
#
# Usage:
#
#     gen-patched-assets.sh -d <output_dir> -t <patch-type> -f <updateinfo_patch> -s <csum-type> -a <source-assets-dir>
#
# Behaviour:
#
# 1. Create a temporary directory.
# 2. Copy assets into this directory.
# 3. Apply a patchfile
# 3.1 if patch-type == 'update', apply it to assets_dir/updateinfo.xml.
# 3.2 if patch-type == 'module', apply it to assets_dir/modules.yaml.
# 3.2 otherwise error and exit
# 4. Call gen-fixtures.sh, and point it at our patched assets.
# 4.1 if csum-type is specified, use it. Otherwise, use 'sha256'
# 5. Remove the temporary directory.
#
set -euo pipefail

checksum_info="sha256"
patchtype="update"
destfile="updateinfo.xml"
src_assets_dir="rpm/assets"
# Read arguments.
while getopts d:t:f:s:a: flag
do
  case "${flag}" in
    d) output_dir="${OPTARG}";;
    t) patchtype="${OPTARG}";;
    f) patchfile=$(realpath "${OPTARG}");;
    s) checksum_info="${OPTARG}";;
    a) src_assets_dir="${OPTARG}";;
    *) echo "Internal error! Encountered unexpected argument: $1"; exit 1;;
  esac
done
echo "output_dir ${output_dir}"
echo "patchtype ${patchtype}"
echo "patchfile ${patchfile}"
echo "checksum_info ${checksum_info}"

# Figure out which file we're patching
if [[ $patchtype == "update" ]]
then
  destfile="updateinfo.xml"
elif [[ $patchtype == "module" ]]
then
  destfile="modules.yaml"
else
  echo "Unknown patch-type $patchtype. Use 'update' or 'module'."
fi
echo "destfile ${destfile}"

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
cp -rt "${assets_dir}" "${src_assets_dir}"/*
patch "${assets_dir}/${destfile}" "${patchfile}"
./rpm/gen-fixtures.sh --checksum-type "${checksum_info}" "${output_dir}" "${assets_dir}"
if [[ $patchtype == "module" ]]
then
  modifyrepo_c --no-compress --mdtype modules "${assets_dir}/${destfile}" "${output_dir}/repodata"
fi
