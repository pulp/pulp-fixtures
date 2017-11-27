#!/usr/bin/env bash
# coding=utf-8
#
# Generate an invalid RPM.
#
set -euo pipefail

# Assume this script has been called from the Pulp Fixtures makefile.
source ./rpm/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-invalid-rpm.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: ${script_name} <output-dir>

Generate an invalid RPM, and place it into <output-dir>. <output-dir> need not
exist.
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
shift

# Create a temporary file.
cleanup() { if [ -n "${temp_file:-}" ]; then rm -f "${temp_file}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
temp_file="$(mktemp)"

# Generate an invalid RPM, and copy it to the output directory.
dd if=/dev/urandom of="${temp_file}" bs=1KB count=1
install -Dm644 "${temp_file}" "${output_dir}/invalid.rpm"
