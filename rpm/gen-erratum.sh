#!/usr/bin/env bash
# coding=utf-8
#
# Generate an erratum that can be uploaded to a Pulp RPM repository.
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
usage: gen-erratum.sh <output_dir> <assets_dir>

Create <output_dir>. Generate an RPM erratum referencing several RPMs from
<assets_dir>, and place the erratum in <output_dir>. The RPM selection algorithm
picks a consistent set of RPMs, so long as the same <assets_dir> is used. The
algorithm never returns two versions of the same RPM.

EOF
cat <<EOF
<output_dir>
    The directory into which the erratum is placed.
<assets_dir>
    The directory from which source material is read.
EOF
}

# Given an RPM filename, echo a JSON description of the RPM.
make_erratum_package() {
cat <<EOF
"arch": "$(get_rpm_arch "${1}")",
"epoch": "$(get_rpm_epoch "${1}")",
"filename": "$(basename "${1}")",
"name": "$(get_rpm_name "${1}")",
"release": "$(get_rpm_release "${1}")",
"src": "$(get_rpm_name "${1}")-$(get_rpm_version "${1}")-$(get_rpm_release "${1}").src.rpm",
"sum": [
    "md5",
    "$(get_md5sum "${1}")",
    "sha256",
    "$(get_sha256sum "${1}")"
],
"version": "$(get_rpm_version "${1}")"
EOF
}

# Given a path to an RPM package, echo the package epoch.
#
# e.g. assets/walrus-5.21-1.noarch.rpm → 0
get_rpm_epoch() {
    local filename
    filename="$(basename "${1}")"
    # If an epoch is listed, return it. Otherwise, assume an epoch of 0.
    case "${filename}" in
        *'!'*)
            echo "${filename#\!*}"
            ;;
        *)
            echo 0
            ;;
    esac
}

# Given a path to an RPM package, echo the package name.
#
# e.g. assets/walrus-5.21-1.noarch.rpm → walrus
get_rpm_name() {
    local filename parts
    filename="$(basename "${1}")"
    IFS=$'\n' parts=($(echo "${filename}" | tr - "\n"))
    echo "${parts[0]#*\!}"  # strip epoch
}

# Given a path to an RPM package, echo the package version.
#
# e.g. assets/walrus-5.21-1.noarch.rpm → 5.21
get_rpm_version() {
    local filename parts
    filename="$(basename "${1}")"
    IFS=$'\n' parts=($(echo "${filename}" | tr - "\n"))
    echo "${parts[1]}"
}

# Given a path to an RPM package, echo the package release.
#
# e.g. assets/walrus-5.21-1.noarch.rpm → 1
get_rpm_release() {
    local filename parts
    filename="$(basename "${1}")"
    IFS=$'\n' parts=($(echo "${filename}" | tr - "\n"))
    echo "${parts[2]%%.*}"
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

# Given a path to a file, echo the file's sha256 checksum.
get_sha256sum() {
    checksum=$(sha256sum "${1}")
    echo "${checksum%% *}"
}

# Given a path to a file, echo the file's md5 checksum.
get_md5sum() {
    checksum=$(md5sum "${1}")
    echo "${checksum%% *}"
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

# Find and sort all RPMs.
rpms=( "${assets_dir}"/*.rpm )
IFS=$'\n' rpms=($(sort <<<"${rpms[*]}"))

# Pick RPMs. Do not select two versions of the same RPM.
picks=("${rpms[0]}")
readonly num_needed=4
for rpm in "${rpms[@]:1}"; do
    # Transform from e.g. "…/assets/walrus-5.21-1.noarch.rpm" to "walrus"
    prev_pick=$(get_rpm_name "${picks[-1]}")
    candidate=$(get_rpm_name "${rpm}")
    if [ "${prev_pick}" == "${candidate}" ]; then
        continue
    fi
    picks+=("${rpm}")
done
if [ "${#picks[@]}" -lt "$num_needed" ]; then
    echo 1>&2 "Need ${num_needed} unique RPMs, but found ${#picks[@]}: ${picks[*]}"
    exit 1
fi

# Create output_dir and generate an erratum.
mkdir "${output_dir}"
cat >"${output_dir}/erratum.json" <<EOF
{
    "description": "Dummy advisory for testing purposes\n",
    "from": "nobody@redhat.com",
    "issued": "2014-09-24 00:00:00",
    "pkglist": [
        {
            "name": "RHSA-2014:1293",
            "packages": [
                {$(make_erratum_package "${picks[0]}")},
                {$(make_erratum_package "${picks[1]}")},
                {$(make_erratum_package "${picks[2]}")},
                {$(make_erratum_package "${picks[3]}")}
            ],
            "short": ""
        }
    ],
    "pushcount": "1",
    "reboot_suggested": false,
    "references": [
        {
            "href": "https://rhn.redhat.com/errata/RHSA-9999-0001.html",
            "id": "RHSA-9999:0001",
            "title": "RHSA-9999:0001",
            "type": "self"
        },
        {
            "href": "https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=1141597",
            "id": "1141597",
            "title": "CVE-2014-6271 bash: specially-crafted environment variables can be used to inject shell commands",
            "type": "bugzilla"
        },
        {
            "href": "https://www.redhat.com/security/data/cve/CVE-2014-6271.html",
            "id": "CVE-2014-6271",
            "title": "CVE-2014-6271",
            "type": "cve"
        },
        {
            "href": "https://access.redhat.com/security/updates/classification/#critical",
            "id": "classification",
            "title": "critical",
            "type": "other"
        }
    ],
    "release": "0",
    "rights": "Copyright 2014 Red Hat Inc",
    "severity": "Critical",
    "solution": "Eat sleep rave repeat\n",
    "status": "final",
    "summary": "This advisory solves nothing\n",
    "title": "Dummy advisory 1",
    "type": "security",
    "updated": "2014-09-24 00:00:00",
    "version": "1"
}
EOF
