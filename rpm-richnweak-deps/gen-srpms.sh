#!/usr/bin/env bash
# coding=utf-8
set -euo pipefail

# Assume this script has been called from the makefile.
source ./rpm-richnweak-deps/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-srpms.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name <output-dir> <specfile>...

Generate SRPM files from .spec files, and place them into <output-dir>.
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

# Populate ~/rpmbuild/SRPMS/
rpmdev-setuptree
for specfile in "${@}"; do
    rpmbuild -bs --target fc30 "${specfile}" &
done
wait

# Copy each SRPM into $working_dir.
for specfile in "${@}"; do
    filename="$(rpm --query --queryformat '%{NEVR}.src.rpm' --specfile "${specfile}")"
    cp ~/rpmbuild/SRPMS/"${filename}" "${working_dir}"/
done
createrepo_c --checksum sha256 "${working_dir}"

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
