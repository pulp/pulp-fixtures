#!/bin/sh

set -eux

SRCDIR=$(readlink -f "$(dirname "$0")")
TMPDIR=$(mktemp -d)
OUTPUTDIR=$(realpath "${SRCDIR}/../$1")

trap 'rm -rf "${TMPDIR}"' EXIT

cd "${TMPDIR}"

echo 'Suite: mythology
Codename: ragnarok
Architectures: ppc64
Components: asgard' > Release

apt-ftparchive release . >> Release

mkdir -p "${OUTPUTDIR}"/dists/fjalar/
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/Release -t "${OUTPUTDIR}"/dists/fjalar/
