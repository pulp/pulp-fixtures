#!/usr/bin/env bash
# coding=utf-8
#
# Generate an RPM repository.
#
set -euo pipefail

# Assume this script has been called from the Pulp Fixtures makefile.
source ./rpm/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-fixtures.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name [options] <output-dir> <assets-dir>

Generate an RPM repository from the RPMs in <assets-dir>. Place the repository's
contents into <output-dir>. <output-dir> need not exist, but all parent
directories must exist.

Options:
    --signing-key <path>
        A private key with which to sign RPMs in the generated repository. The
        corresponding public key must have a uid (name) of "Pulp QE". (You can
        check this by executing 'gpg public-key' and examining the "uid" field.)
    --packages-dir <relative-path>
        The path in which to place packages, relative to the root of the
        repository. If not specified, packages are placed in the root of the
        repository. Passing \`--packages-dir .\` is equivalent to the default
        action.
    --checksum-type <type>
        The type of checksum that has to be included in repomd while using the
        $(createrepo) command. Default checksum type is sha256.
    --zchunk
        Whether or not to run createrepo with --zck option.

EOF
}

# Transform $@. $temp is needed. If omitted, non-zero exit codes are ignored.
check_getopt
temp=$(getopt \
    --options '' \
    --longoptions signing-key:,packages-dir:,checksum-type:,zchunk \
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
        --signing-key) signing_key="$(realpath --canonicalize-existing "$2")"; shift 2;;
        --packages-dir) packages_dir="$2"; shift 2;;
        --checksum-type) checksum_type="$2"; shift 2;;
        --zchunk) zchunk="--zck"; shift 1;;
        --) shift; break;;
        *) echo "Internal error! Encountered unexpected argument: $1"; exit 1;;
    esac
done
output_dir="$(realpath "$1")"
assets_dir="$(realpath --canonicalize-existing "$2")"
shift 2

# Create a workspace, and schedule it for deletion.
cleanup() { if [ -n "${working_dir:-}" ]; then rm -rf "${working_dir}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
working_dir="$(mktemp --directory)"
packages_dir="$(realpath --canonicalize-missing "${working_dir}/${packages_dir:-}")"
if [ "${working_dir}" != "${packages_dir}" ]; then
    mkdir -p "${packages_dir}"
fi

# Sign RPMs and genereate repository metadata.
#
# NOTE: --groupfile should not be in $output_dir, but createrepo requires that
# --groupfile be relative to $output_dir. Thus, the relative path calculation.
cp --reflink=auto -t "${packages_dir}" "${assets_dir}/"*.rpm
if [ -n "${signing_key:-}" ]; then
    find "${working_dir}" -name '*.rpm' -print0 | xargs -0 rpmsign \
        --define '_gpg_name Pulp QE' --addsign --fskpath "${signing_key}" \
        --signfiles
fi
checksum_type_default=sha256
createrepo ${zchunk:-} --checksum "${checksum_type:-${checksum_type_default}}" \
    --groupfile "$(realpath --relative-to "${working_dir}" "${assets_dir}/comps.xml")" \
    "${working_dir}"
modifyrepo --mdtype updateinfo \
    "${assets_dir}/updateinfo.xml" \
    "${working_dir}/repodata/"

# Copy fixtures to $output_dir.
#
# A $working_dir is used to make fixture generation more atomic. If fixture
# generation fails, this script (or the calling make target) can be run again
# without worrying about cleanup work. $working_dir is copied rather than moved
# to prevent cleanup() from reaping an innocent directory. --no-preserve is used
# because `mktemp -d` creates directories with a mode of 700, and a mode of 755
# (or whatever the umask dictates) is desired.
if [ -d "${output_dir}" ]; then
    cp -r --no-preserve=mode --reflink=auto "${working_dir}"/* "${output_dir}"
else
    cp -r --no-preserve=mode --reflink=auto "${working_dir}" "${output_dir}"
fi
