#!/usr/bin/env bash
#
# Generate an RPM.
#
set -euo pipefail

# Assume this script has been called from the Pulp Fixtures makefile.
source ./rpm/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-rpm.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name <output-dir> <spec-file>

Generate an RPM from the <spec-file>. Place the result into <output-dir>.
<output-dir>. <output-dir> need not exist.
EOF
}

# Transform $@. $temp is needed. If omitted, non-zero exit codes are ignored.
check_getopt
temp=$(getopt --name "$script_name" -o '+' -- "$@")
eval set -- "$temp"
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

# Copy the spec file into the workspace and generate an RPM.
cp "${spec_file}" "${working_dir}/"
(
    cd "${working_dir}"
    fedpkg --release f25 local
    install -Dm644 \
        "noarch/$(basename "${spec_file%.spec}")-1-1.fc25.noarch.rpm" \
        "${output_dir}/$(basename "${spec_file%.spec}")-1-1.fc25.noarch.rpm"
)
