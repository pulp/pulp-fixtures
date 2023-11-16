#!/usr/bin/env bash
# coding=utf-8
#
# Generate an RPM and a repository for that RPM.
#
set -euo pipefail

# Assume this script has been called from the Pulp Fixtures makefile.
source ./rpm/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-rpm-and-repo.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: ${script_name} <output-dir> <spec-file>

Generate an RPM from the <spec-file>. Generate metadata referencing that RPM.
Move the resulting repository to <output-dir>. <output-dir> need not exist.
EOF
}

# Transform $@. $temp is needed. If omitted, non-zero exit codes are ignored.
check_getopt
temp=$(getopt --name "${script_name}" -o '+' -- "$@")
eval set -- "${temp}"
unset temp

# Read arguments. (getopt inserts -- even when no arguments are passed.)
if [ "${#@}" -eq 1 ]; then
    show_help
    exit 0
fi
while true; do
    case "$1" in
        --) shift; break;;
        *) echo "Internal error! Encountered unexpected argument: $1"; exit 1;;
    esac
done
output_dir="$(realpath "$1")"
spec_file="$(realpath --canonicalize-existing "$2")"
shift 2

# Create a workspace, and schedule it for deletion.
cleanup() { if [ -n "${working_dir:-}" ]; then rm -rf "${working_dir}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
working_dir="$(mktemp --directory)"

# Generate an RPM, and generate repository metadata for it.
./rpm/gen-rpm.sh "${working_dir}" "${spec_file}"
createrepo_c --general-compress-type gz --checksum sha256 "${working_dir}"

# Copy repository to destination.
#
# The working directory is copied rather than moved to prevent cleanup() from
# reaping an innocent directory. --no-preserve is used because `mktemp -d`
# creates directories with a mode of 700, and a mode of 755 (or whatever the
# umask dictates) is desired.
cp -r --no-preserve=mode --reflink=auto "${working_dir}" "${output_dir}"
