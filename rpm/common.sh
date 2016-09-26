#!/usr/bin/env bash
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
