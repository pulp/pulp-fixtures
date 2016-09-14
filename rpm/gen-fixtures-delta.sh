#!/usr/bin/env bash
#
# Generate RPM repository with DRPM fixture data.
# Several RPM utilities must be installed, including `createrepo` and `makedeltarpm`.
#
set -euo pipefail

#------------------------------------------------------------------------------
# Helper Functions
#------------------------------------------------------------------------------

# Print a message to stdout explaining how to use this script.
#
# NOTE: $0 corresponds to the the script's name only in some shells and in some
# contexts.
show_help() {
fmt <<EOF
usage: gen-fixtures-delta.sh <output_dir> <assets_dir>

Create <output_dir>. Walk through the RPMs in <assets_dir>, and generate a DRPM
for each adjacent pair of RPMs. Copy the source RPMs to <output_dir>, and place
the generated DRPMs in <output_dir>/drpms.

The RPMs in <assets_dir> should be related. (It doesn't make sense to generate a
DRPM for upgrading from firefox to gimp.) This script will exit with a non-zero
exit code if any adjacent pair of RPMs have differing base package names or
architectures.

EOF
cat <<EOF
<output_dir>
    The directory into which generated fixtures are placed.
<assets_dir>
    The directory from which RPMs are read.
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
    assets_dir="$(realpath --canonicalize-existing "${2}")"
fi

# Create and populate ${output_dir}, and verify that we have enough RPMs.
mkdir -vp "${output_dir}/drpms"
cp -t "${output_dir}" "${assets_dir}/"*.rpm
rpms=( "${output_dir}/"*.rpm )
readonly num_rpms=${#rpms[@]}
readonly num_needed=2
if [ "${num_rpms}"  -lt "${num_needed}" ]; then
    echo 1>&2 "Error: Need at least ${num_needed} RPMS, but found ${num_rpms}."
    exit 1
fi

# Make DRPMs from RPMs.
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
        "${output_dir}/drpms/${name_2}-${ver_1}-${rel_1}_${ver_2}-${rel_2}.${arch_2}.drpm"
done

# Generate repodata directory.
createrepo --checksum sha256 --deltas "${output_dir}"
