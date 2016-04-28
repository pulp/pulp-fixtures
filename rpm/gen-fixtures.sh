#!/usr/bin/env sh
#
# Generate RPM repository fixture data. Several RPM utilities must be installed,
# including `createrepo` and `modifyrepo`.
#
set -euo pipefail

# NOTE: $0 corresponds to the the script's name only in some shells and in some
# contexts.
show_help() {
fmt <<EOF
usage: gen-fixtures.sh <output_dir> <assets_dir>

Create <output_dir>. Use <assets_dir> to generate RPM fixture data and place the
results into <output_dir>. A suggested name for <output_dir> is "zoo".

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

# Create output_dir and generate fixture data from assets_dir.
# NOTE: --groupfile should not be in $output_dir, but createrepo requires that
# --groupfile be relative to $output_dir. Thus, the relative path calculation.
mkdir "${output_dir}"
cp -t "${output_dir}" "${assets_dir}/"*.rpm
createrepo --checksum sha256 \
    --groupfile "$(realpath --relative-to "${output_dir}" "${assets_dir}/comps.xml")" \
    "${output_dir}"
modifyrepo --mdtype updateinfo \
    "${assets_dir}/updateinfo.xml" \
    "${output_dir}/repodata/"
