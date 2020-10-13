#!/bin/sh

set -eux

SRCDIR=$(readlink -f "$(dirname "$0")")
TMPDIR=$(mktemp -d)
OUTPUTDIR=$(realpath "${SRCDIR}/../$1")

trap 'rm -rf "${TMPDIR}"' EXIT

cd "${TMPDIR}"
(
  for CTL in "${SRCDIR}"/asgard/*.ctl
  do
    equivs-build --arch ppc64 "${CTL}"
  done
)

dpkg-scanpackages . | tee ./Packages | gzip > ./Packages.gz

echo 'Suite: mythology
Codename: ragnarok
Architectures: ppc64
Components: asgard' > Release

apt-ftparchive release . >> Release

mkdir -p "${OUTPUTDIR}"/nest/fjalar/
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/. -t "${OUTPUTDIR}"
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/Release -t "${OUTPUTDIR}"/nest/fjalar/
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/Packages -t "${OUTPUTDIR}"/nest/fjalar/
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/Packages.gz -t "${OUTPUTDIR}"/nest/fjalar/
