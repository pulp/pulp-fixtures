#!/usr/bin/env bash
#
# Generate a PyPI-compatible Python repository.
#
set -euo pipefail

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-fixtures.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name <output-dir> <assets-dir> <base-url>

Generate a PyPI-compatible Python repository from the data in <assets-dir>.
Place the repository's contents into <output-dir>. <output-dir> need not exist,
but all parent directories must exist.

<base-url> is the URL of where the fixtures will be hosted. It is needed for
generating absolute URLs.
EOF
}

# Fetch arguments from user.
if [ "$#" -lt 3 ]; then
    echo 1>&2 'Error: Too few arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
elif [ "$#" -gt 3 ]; then
    echo 1>&2 'Error: Too many arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
fi
output_dir="$(realpath "$1")"
assets_dir="$(realpath --canonicalize-existing "$2")"
base_url="$3"

# Create a workspace, and schedule it for deletion.
cleanup() { if [ -n "${working_dir:-}" ]; then rm -rf "${working_dir}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
working_dir="$(mktemp --directory)"

# Twiddle with repository, and copy it to its final destination.
cp -r --reflink=auto -t "$working_dir" "$assets_dir"/*
sed -i -e "s|BASE_URL|$base_url|g" \
    "$working_dir"/pypi/shelf-reader/json/index.json
cp -r --no-preserve=mode --reflink=auto "$working_dir" "$output_dir"
