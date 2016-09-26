#!/usr/bin/env bash
#
# Generate RPM repository with DRPM fixture data.
#
set -euo pipefail

# Assume this script has been called from the Pulp Fixtures makefile.
source ./rpm/common.sh

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-fixtures-delta.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name [options] <output-dir> <assets-dir>

Generate a DRPM repository from the RPMs in <assets-dir>. Place the repository's
contents into <output-dir>, with RPMs in <output-dir> and DRPMs in
<output-dir>/drpms. <output-dir> need not exist, but all parent directories must
exist.

Exit with a non-zero exit code if any adjacent pair of RPMs in <assets-dir> have
differing base package names or architectures. (In other words, the source RPMs
must be related. It doesn't make sense to generate a DRPM for upgrading from
firefox to gimp.)

Options:
    --signing-key <signing-key>
        A private key with which to sign DRPMs in the generated repository. The
        corresponding public key must have a uid (name) of "Pulp QE". (You can
        check this by executing 'gpg public-key' and examining the "uid" field.)
EOF
}

# Given a path to an RPM package, echo the package name.
#
# e.g. assets/walrus-baby-5.21-1.noarch.rpm → walrus-baby
get_rpm_name() {
    local filename parts end
    filename="$(basename "${1}")"
    IFS=$'\n' parts=($(echo "${filename}" | tr - "\n"))
    end=$(( ${#parts[@]} - 2 ))
    for ((i=0; i< end ; i++)); do
        rpm_name+="${parts[i]}"-
    done
    rpm_name="${rpm_name::-1}"
    echo "${rpm_name#*\!}"  # strip epoch
}

# Given a path to an RPM package, echo the package version.
#
# e.g. assets/walrus-5.21-1.noarch.rpm → 5.21
get_rpm_version() {
    local filename parts
    filename="$(basename "${1}")"
    IFS=$'\n' parts=($(echo "${filename}" | tr - "\n"))
    echo "${parts[-2]}"
}

# Given a pathto an RPM package, echo the package release.
#
# e.g. assets/yum-cron-3.4.3-10.fc16.noarch.rpm  → 10.fc16
get_rpm_release() {
    local filename parts
    filename="$(basename "${1}")"
    IFS=$'\n' parts=($(echo "${filename}" | tr - "\n"))
    last_part="${parts[-1]}"
    pattern="${2}.rpm"

    release="${last_part%.$pattern}"
    echo "${release}"
}

# Given a path to an RPM package, echo the package arch.
#
# e.g. assets/walrus-5.21-1.noarch.rpm → noarch
get_rpm_arch() {
    local filename parts
    filename="$(basename "${1}")"
    IFS=$'\n' parts=($(echo "${filename}" | tr . "\n"))
    echo "${parts[-2]}"
}

#------------------------------------------------------------------------------
# Business Logic
#------------------------------------------------------------------------------

# Transform $@. $temp is needed. If omitted, non-zero exit codes are ignored.
check_getopt
temp=$(getopt --options '' --longoptions signing-key: --name "$script_name" -- "$@")
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

# Copy RPMs to workspace, and verify that we have enough RPMs.
cp --reflink=auto -t "${working_dir}" "${assets_dir}/"*.rpm
rpms=( "${working_dir}/"*.rpm )
readonly num_rpms=${#rpms[@]}
readonly num_needed=2
if [ "${num_rpms}"  -lt "${num_needed}" ]; then
    echo 1>&2 "Error: Need at least ${num_needed} RPMS, but found ${num_rpms}."
    exit 1
fi

# Make DRPMs from RPMs.
mkdir "${working_dir}/drpms"
IFS=$'\n' rpms=($(sort <<<"${rpms[*]}"))  # sort files by name
for (( i=0; i < num_rpms - 1; i++ )); do
    rpm_1="${rpms[i]}"
    rpm_2="${rpms[i+1]}"

    name_1="$(get_rpm_name "${rpm_1}")"
    name_2="$(get_rpm_name "${rpm_2}")"
    if [ "${name_1}" != "${name_2}" ]; then
        fmt 1>&2 <<EOF
Error: Old and new packages must have the same name, but are different. Package
names are ${name_1} and ${name_2}. (From ${rpm_1} and ${rpm_2}.)
EOF
        exit 1
    fi

    arch_1="$(get_rpm_arch "${rpm_1}")"
    arch_2="$(get_rpm_arch "${rpm_2}")"
    if [ "${arch_1}" != "${arch_2}" ]; then
        fmt 1>&2 <<EOF
Error: Old and new packages must have the same architecture, but are different.
Package architectures are ${arch_1} and ${arch_2}. (From ${rpm_1} and ${rpm_2}.)
EOF
        exit 1
    fi

    ver_1="$(get_rpm_version "${rpm_1}")"
    ver_2="$(get_rpm_version "${rpm_2}" )"
    rel_1="$(get_rpm_release "${rpm_1}" "${arch_1}")"
    rel_2="$(get_rpm_release "${rpm_2}" "${arch_2}")"
    makedeltarpm "${rpm_1}" "${rpm_2}" \
        "${working_dir}/drpms/${name_2}-${ver_1}-${rel_1}_${ver_2}-${rel_2}.${arch_2}.drpm"
done

# Sign DRPMs and generate repository metadata.
if [ -n "${signing_key:-}" ]; then
    find "${working_dir}" -name '*.drpm' -print0 | xargs -0 rpmsign \
        --define '_gpg_name Pulp QE' --addsign --fskpath "${signing_key}" \
        --signfiles
fi
createrepo --checksum sha256 --deltas "${working_dir}"

# Copy fixtures to $output_dir. For an explanation, see gen-fixtures.sh.
cp -r --no-preserve=mode --reflink=auto "${working_dir}" "${output_dir}"
