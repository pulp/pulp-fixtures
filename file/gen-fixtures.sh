#!/usr/bin/env bash
#
# Generate a file repository.
#
set -euo pipefail

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: gen-fixtures.sh <output-dir>

Generate a file repository with pseudo ISO files (generated with bytes from
/dev/urandom) with different filesize. Then generate the PULP_MANIFEST file
describring the generated files.

Place the repository's contents into <output-dir>. <output-dir> need not exist,
but all parent directories must exist.
EOF
}

# Fetch output_dir from user.
if [ "$#" -lt 1 ]; then
    echo 1>&2 'Error: Too few arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
elif [ "$#" -gt 1 ]; then
    echo 1>&2 'Error: Too many arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
else
    output_dir="$(realpath --canonicalize-missing "${1}")"
fi

# Create the output dir and a blank PULP_MANIFEST file
mkdir "${output_dir}"
touch "${output_dir}/PULP_MANIFEST"

# Create the pseudo ISO files and update the PULP_MANIFEST with the generated
# file information
for i in {1..3}; do
    output="${output_dir}/${i}.iso"
    dd if=/dev/urandom of="${output}" bs="${i}M" count=1
    line=${i}.iso,"$(sha256sum "${output}" | awk '{ print $1 }')","$(stat -c '%s' "${output}")"
    echo "${line}" >> "${output_dir}/PULP_MANIFEST"
done
