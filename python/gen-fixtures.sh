#!/usr/bin/env sh
#
# Copy static Python files into a destination directory.
#
set -euo pipefail

# NOTE: $0 corresponds to the the script's name only in some shells and in some
# contexts.
show_help() {
fmt <<EOF
usage: gen-fixtures.sh <output_dir> <assets_dir>

Create <output_dir>. Copy Python fixture data from <assets_dir> and place the 
results into <output_dir>.

EOF
cat <<EOF
<output_dir>
    The directory into which generated fixtures are placed.
<assets_dir>
    The directory from which source material is read.
EOF
}

# Fetch output_dir from user.
if [ "$#" -lt 2 ]; then
    echo 1>&2 'Error: Too few arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
elif [ "$#" -gt 2 ]; then
    echo 1>&2 'Error: Too many arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
else
    output_dir="$(realpath --canonicalize-missing "${1}")"
    assets_dir="$(realpath "${2}")"
fi

# Create output_dir and generate fixture data.
mkdir "${output_dir}"
cp -rt "${output_dir}" "${assets_dir}"/*
