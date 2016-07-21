#!/usr/bin/env bash
#
# Generate RPM repository with DRPM fixture data.
# Several RPM utilities must be installed, including `createrepo` and `makedeltarpm`.
#
set -euo pipefail

# Print a message to stdout explaining how to use this script.
#
# NOTE: $0 corresponds to the the script's name only in some shells and in some
# contexts.
show_help() {
fmt <<EOF
usage: gen-fixtures-delta.sh <output_dir> <assets_dir> <dpkg_name>

Create <output_dir>. Use packages in <assets_dir> to generate DRPM fixture data
for package <dpkg_name> and place the results into <output_dir>.
A suggested name for <output_dir> is "zoo".

EOF
cat <<EOF
<output_dir>
    The directory into which generated fixtures are placed.
<assets_dir>
    The directory from which source material is read.
 <dpkg_name>
    The name of package which delta RPM will be generated for
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


# Fetch output_dir from user.
if [ "$#" -lt 3 ]; then
    echo 1>&2 'Error: Too few arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
elif [ "$#" -gt 3 ]; then
    echo 1>&2 'Error: Too many arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
else
    output_dir="$(realpath --canonicalize-missing "${1}")"
    assets_dir="$(realpath --canonicalize-existing "${2}")"
    package_name="${3}"
fi

# Copy all RPMs from assets_dir to output_dir
# Create directory 'drpms' for DRPMS
mkdir -vp "${output_dir}/drpms"
cp -t "${output_dir}" "${assets_dir}/"*.rpm

# Filter and sort all required RPMs.
rpms=( "${output_dir}/${package_name}"*.rpm )
IFS=$'\n' rpms=($(sort <<<"${rpms[*]}"))

found_rpms=()
for (( i=0; i<${#rpms[@]}; i++ ));
do
    current_package_name="$(get_rpm_name "${rpms[i]}")"
    if [ "${current_package_name}" == "${package_name}" ]; then
        found_rpms+=("${rpms[i]}")
    fi
done

readonly num_needed=2
rpms_len=${#found_rpms[@]}
if [ "${rpms_len}"  -lt "${num_needed}" ]; then
    echo 1>&2 "Error: Need at least ${num_needed} RPMS. But found ${rpms_len}"
    exit 1
fi

# Make DRPMS from RPMS
# DRPMS is generated from all neighbouring RPMS in filtered RPMS list
for (( i=0; i < rpms_len - 1; i++ ));
do
    pkg_1="${found_rpms[i]}"
    pkg_2="${found_rpms[i+1]}"

    name_1="$(get_rpm_name "${pkg_1}")"
    name_2="$(get_rpm_name "${pkg_2}")"

    if [ "${name_1}" != "${name_2}" ]; then
        fmt 1>&2 <<EOF
Error: Old and new packages must have the same name, but are different. Package
names are ${name_1} and ${name_2}.
EOF
        exit 1
    fi

    arch_1="$(get_rpm_arch "${pkg_1}")"
    arch_2="$(get_rpm_arch "${pkg_2}")"

    if [ "${arch_1}" != "${arch_2}" ]; then
        fmt 1>&2 <<EOF
Error: Old and new packages must have the same architecture, but are different.
Package architectures are ${arch_1} and ${arch_2}.
EOF
        exit 1
    fi

    ver_1="$(get_rpm_version "${pkg_1}")"
    ver_2="$(get_rpm_version "${pkg_2}" )"

    rel_1="$(get_rpm_release "${pkg_1}" "${arch_1}")"
    rel_2="$(get_rpm_release "${pkg_2}" "${arch_2}")"

    dpkg="${name_2}-${ver_1}-${rel_1}_${ver_2}-${rel_2}.${arch_2}.drpm"

    makedeltarpm "${pkg_1}" "${pkg_2}" "${output_dir}"/drpms/"${dpkg}"
done

# Generate DRPMS fixtures from RPMS and DRPMS
createrepo --checksum sha256 --delta "${output_dir}"
