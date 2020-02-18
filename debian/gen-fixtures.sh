#!/bin/sh

set -eux

SRCDIR=$(readlink -f "$(dirname "$0")")
TMPDIR=$(mktemp -d)
OUTPUTDIR=$(realpath "${SRCDIR}/../$1")

trap 'rm -rf "${TMPDIR}"' EXIT

cd "${TMPDIR}"

mkdir asgard
(
  cd asgard

  for CTL in "${SRCDIR}"/asgard/*.ctl
  do
    equivs-build --arch ppc64 "${CTL}"
  done
)

mkdir asgard_udebs
(
  cd asgard_udebs

  for CTL in "${SRCDIR}"/asgard_udebs/*.ctl
  do
    equivs-build --arch ppc64 "${CTL}"
  done
  for DEB in *.deb
  do
    mv "$DEB" "${DEB%deb}udeb"
  done
)

mkdir jotunheimr
(
  cd jotunheimr

  for CTL in "${SRCDIR}"/jotunheimr/*.ctl
  do
    equivs-build --arch armeb "${CTL}"
  done
)

cp -a "${SRCDIR}/conf" .
reprepro -C asgard includeudeb ragnarok asgard_udebs/*.udeb
reprepro -C asgard includedeb ragnarok asgard/*.deb
reprepro -C asgard includedeb nosuite asgard/*.deb
reprepro -C jotunheimr includedeb ragnarok jotunheimr/*.deb

rm dists/ragnarok/jotunheimr/binary-armeb/Packages

mkdir -p "${OUTPUTDIR}"
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/dists -t "${OUTPUTDIR}"
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/pool -t "${OUTPUTDIR}"
