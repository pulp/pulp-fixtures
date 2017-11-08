#!/usr/bin/env bash
# coding=utf-8
#
# Generate a Puppet module.
#
set -euo pipefail

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-module.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name <output-dir>

Generate a puppet module and place it in <output-dir>. <output-dir> need not
exist, but all parent directories must exist.
EOF
}

# Fetch arguments from user.
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
fi
output_dir="$(realpath "$1")"
module_name=pulpqe-dummypuppet  # we can parameterize this if need be

# Create a workspace, and schedule it for deletion.
cleanup() { if [ -n "${temp_dir:-}" ]; then rm -rf "${temp_dir}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
temp_dir="$(mktemp --directory)"

(
    cd "$temp_dir"
    puppet module generate --skip-interview "${module_name}"
    tar -czf "${module_name}.tar.gz" "${module_name#*-}"
)
install -Dm644 "${temp_dir}/${module_name}.tar.gz" \
    "${output_dir}/${module_name}.tar.gz"
