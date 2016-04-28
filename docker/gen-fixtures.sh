#!/usr/bin/env sh
#
# Use `docker save` to create a tarball that can be uploaded to a Pulp Docker
# repository. Docker must be installed and available for use.
#
set -euo pipefail
readonly image_name='busybox:latest'

# NOTE: $0 corresponds to the the script's name only in some shells and in some
# contexts.
show_help() {
fmt <<EOF
usage: gen-fixtures.sh <output_dir>

Create <output_dir>. Generate Docker fixture data and place the results into
<output_dir>.

EOF
cat <<EOF
<output_dir>
    The directory into which generated fixtures are placed.
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

# Create output_dir and generate fixture data.
mkdir "${output_dir}"
docker pull "$image_name"
docker save "$image_name" > "${output_dir}/${image_name}.tar"
