#!/usr/bin/env bash
# coding=utf-8
#
# Generate a PyPI-compatible Python repository.
#
set -euo pipefail

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-fixtures.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name <output-dir> <base-url>

Generate a PyPI-compatible Python repository from the data in projects.json.
Place the repository's contents into <output-dir>. <output-dir> need not exist,
but all parent directories must exist.

<base-url> is the URL of where the fixtures will be hosted. It is needed for
generating absolute URLs.
EOF
}

# Fetch arguments from user.
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
fi
output_dir="$(realpath "$1")"
base_url="$2"


./python/gen-pypi-repo.py "${output_dir}" "${base_url}" "python/projects.json"
