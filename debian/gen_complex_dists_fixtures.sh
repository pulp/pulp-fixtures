#!/bin/bash

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

mkdir jotunheimr
(
  cd jotunheimr

  for CTL in "${SRCDIR}"/jotunheimr/*.ctl
  do
    equivs-build --arch armeb "${CTL}"
  done
)

COMMON_REPREPRO_OPTIONS=(
  --confdir
  "${SRCDIR}/complex_dists_conf"
)

# Create the Debian security like repo fixture:
reprepro "${COMMON_REPREPRO_OPTIONS[@]}" -C asgard includedeb ragnarok/updates asgard/*.deb
reprepro "${COMMON_REPREPRO_OPTIONS[@]}" -C jotunheimr includedeb ragnarok/updates jotunheimr/*.deb

# Also create the Ubuntu backports like repo fixture:
reprepro "${COMMON_REPREPRO_OPTIONS[@]}" -C asgard includedeb ragnarok-backports asgard/*.deb
reprepro "${COMMON_REPREPRO_OPTIONS[@]}" -C jotunheimr includedeb ragnarok-backports jotunheimr/*.deb

RAGNAROK_BACKPORTS_RELEASE_FILE="${TMPDIR}/dists/ragnarok-backports/Release"

# Actually alter the Codename in the release file like Ubuntu does:
sed -i "s/Codename: ragnarok-backports/Codename: ragnarok/g" "${RAGNAROK_BACKPORTS_RELEASE_FILE}"

# Now sign the Ubuntu like fixtures using an external singing script:
"${SRCDIR}/sign_deb_release.sh" "${RAGNAROK_BACKPORTS_RELEASE_FILE}"

mkdir -p "${OUTPUTDIR}"
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/dists -t "${OUTPUTDIR}"
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/pool -t "${OUTPUTDIR}"
