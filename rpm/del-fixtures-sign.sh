#!/usr/bin/env bash
#
# Delete signatures of all packages recursively in target directory.
# One RPM utility `rpmsign` must be installed.

set -euo pipefail

# Print a message to stdout explaining how to use this script.
#
# NOTE: $0 corresponds to the the script's name only in some shells and in some
# contexts.
show_help() {
fmt <<EOF
usage: del-fixtures-sign.sh <target_dir>

Recursively delete signatures from all RPM/SRPM/DRPM files in <target_dir>

EOF
cat <<EOF
<target_dir>
    The directory from which package signatures will be removed.
EOF
}

# Fetch target_dir from user.
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
    target_dir="$(realpath --canonicalize-existing "${1}")"
fi

# Recursively delete signatures from packages in target_dir
find "${target_dir}" \( -name '*.rpm' -o -name '*.srpm' -o -name '*.drpm' \) \
    -print0 | xargs -0 rpmsign --delsign
