#!/usr/bin/env bash
# coding=utf-8
#
# Re-usable functions for use by the other RPM-generation scripts.

# Verify that getopt(1) supports modern option parsing.
check_getopt() {
    if [ "$(getopt --test || true)" != '' ]; then
        fmt 1>&2 <<EOF
An old version of getopt is installed. Its limitations include being unable to
cope with whitespace and other shell-specific special characters. Please upgrade
getopt, or execute this script on a more up-to-date system.

Execute 'getopt --test' to see if getopt is new enough. A modern getopt will
print no output and return 4. A traditional getopt will print '--' and return 0.
For more information, see getopt(1).

This script will now exit, so as to avoid possibly causing damage.
EOF
        exit 1
    fi
}

# Given the path to an RPM, return its epoch.
#
# Examples:
#
#   'assets/1!baby-walrus-5.21-1.noarch.rpm' → 1
#   'assets/baby-walrus-5.21-1.noarch.rpm' → 0
get_rpm_epoch() {
    local filename
    filename="$(basename "${1}")"
    case "${filename}" in
        *'!'*)
            echo "${filename%\!*}"
            ;;
        *)
            echo 0
            ;;
    esac
}

# Given the path to an RPM, return its name.
#
# Example: 'assets/1!baby-walrus-5.21-1.noarch.rpm' → baby-walrus
get_rpm_name() {
    local filename
    filename="$(basename "${1}")"
    filename="${filename#*\!}"  # strip epoch
    filename="${filename%-*}"  # strip release and architecture
    filename="${filename%-*}"  # strip version
    echo "${filename}"
}

# Given the path to an RPM, return its version.
#
# Example: 'assets/1!baby-walrus-5.21-1.noarch.rpm' → 5.21
get_rpm_version() {
    local filename
    filename="$(basename "${1}")"
    filename="${filename#*\!}"  # strip epoch
    filename="${filename%-*}"  # strip release and architecture
    filename="${filename##*-}"  # strip name
    echo "${filename}"
}

# Given the path to an RPM, return its release.
#
# Example: 'assets/1!baby-walrus-5.21-1.noarch.rpm' → 1
get_rpm_release() {
    local filename
    filename="$(basename "${1}")"
    filename="${filename##*-}"  # strip epoch, name and version
    filename="${filename%%.*}"  # strip architecture
    echo "${filename}"
}

# Given the path to an RPM, return its architecture.
#
# Example: 'assets/1!baby-walrus-5.21-1.noarch.rpm' → noarch.rpm
get_rpm_architecture() {
    local filename
    filename="$(basename "${1}")"
    filename="${filename##*-}"  # strip epoch, name and version
    filename="${filename#*.}"  # strip release
    echo "${filename}"
}
