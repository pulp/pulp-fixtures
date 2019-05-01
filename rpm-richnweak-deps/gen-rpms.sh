#!/usr/bin/env bash
# coding=utf-8
set -euo pipefail

# Assume this script has been called from the makefile.
source rpm-richnweak-deps/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-rpms.sh'

readonly mock_env=fedora-30-x86_64

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name <output-dir> <srpm>...

Generate RPM files from SRPM files, and place them into <output-dir>.
<output-dir> need not exist, but all parent directories must exist.
EOF
}

# Transform $@. $temp is needed. If omitted, non-zero exit codes are ignored.
check_getopt
temp=$(getopt \
    --options '' \
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
        --) shift; break;;
        *) echo "Internal error! Encountered unexpected argument: $1"; exit 1;;
    esac
done
output_dir="$(realpath -m "$1")"
shift 1

# Create a workspace, and schedule it for deletion.
cleanup() { if [ -n "${working_dir:-}" ]; then rm -rf "${working_dir}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
working_dir="$(mktemp --directory)"

# Generate RPMs, and copy them into $working_dir. Must be done serially, as mock
# blows away the results directory during each run.
mock --root "${mock_env}" --init
for srpm in "${@}"; do
    mock --root "${mock_env}" "${srpm}"
    filename="$(basename "${srpm}")"
    filename="${filename%.src.rpm}.noarch.rpm"
    cp "/var/lib/mock/${mock_env}/result/${filename}" "${working_dir}/"
done
createrepo --checksum sha256 "${working_dir}"
# Create or populate $output_dir.
#
# A $working_dir is used to make fixture generation more atomic. If fixture
# generation fails, this script (or the calling make target) can be run again
# without worrying about cleanup work. $working_dir is copied rather than moved
# to prevent cleanup() from reaping an innocent directory. --no-preserve is used
# because `mktemp -d` creates directories with a mode of 700, and a mode of 755
# (or whatever the umask dictates) is desired.
mkdir -p "$(dirname "${output_dir}")"
if [ -d "${output_dir}" ]; then
    cp -r --no-preserve=mode --reflink=auto "${working_dir}"/* "${output_dir}"
else
    cp -r --no-preserve=mode --reflink=auto "${working_dir}" "${output_dir}"
fi
