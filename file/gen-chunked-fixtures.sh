#!/usr/bin/env bash
# coding=utf-8
#
# Generate a file reository with chunked files.
#
set -euo pipefail

# Assume this script has been called from the Pulp Fixtures makefile.
source ./rpm/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-chunked-fixtures.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: gen-chunked-fixtures.sh <output-dir>

Generate several pseudo-random ISO file and a PULP_MANIFEST file describing
them. Split the ISO generate file in 2 chunks. Place them into a directory at
<output-dir>. <output-dir> need not exist, but all parent directories must
exist.

    --file-size <size>
        The size of ISO files to generate. Default: 10M.
EOF
}

# Transform $@. $temp is needed. If omitted, non-zero exit codes are ignored.
check_getopt
temp=$(getopt \
    --options '' \
    --longoptions file-size: \
    --name "$script_name" \
    -- "$@")
eval set -- "$temp"
unset temp


# Read arguments. (getopt inserts -- even when no arguments are passed.)
if [ "${#@}" -eq 1 ]; then
    show_help
    exit 0
fi
while true; do
    case "$1" in
        --file-size) file_size="$2"; shift 2;;
        --) shift; break;;
        *) echo "Internal error! Encountered unexpected argument: $1"; exit 1;;
    esac
done
output_dir="$(realpath "$1")"
shift

# Create a workspace, and schedule it for deletion.
cleanup() { if [ -n "${working_dir:-}" ]; then rm -rf "${working_dir}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
working_dir="$(mktemp --directory)"

# Create the pseudo ISO files and update the PULP_MANIFEST with the generated
# file information. Split the ISO generate file in 2 chunks.
file_size="${file_size:-1M}"
of="${working_dir}/1.iso"
dd if=/dev/urandom of="${of}" bs="${file_size}" count=1
echo "$(basename "${of}"),$(sha256sum "${of}" | awk '{print $1}'),$(stat -c '%s' "${of}")" \
>> "${working_dir}/PULP_MANIFEST"
cd "${working_dir}"
split --bytes=600K "${of}" chunk

# Copy fixtures to $output_dir.
#
# A $working_dir is used to make fixture generation more atomic. If fixture
# generation fails, this script (or the calling make target) can be run again
# without worrying about cleanup work. $working_dir is copied rather than moved
# to prevent cleanup() from reaping an innocent directory. --no-preserve is used
# because `mktemp -d` creates directories with a mode of 700, and a mode of 755
# (or whatever the umask dictates) is desired.
if [ -d "${output_dir}" ]; then
    cp -r --no-preserve=mode --reflink=auto "${working_dir}"/* "${output_dir}"
else
    cp -r --no-preserve=mode --reflink=auto "${working_dir}" "${output_dir}"
fi
