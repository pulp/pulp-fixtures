#!/bin/sh

set -eux

SRCDIR=$(readlink -f "$(dirname "$0")")
OUTPUTDIR=$(realpath "${SRCDIR}/../$1")
INPUTDIR=$(realpath "${SRCDIR}/../fixtures/debian")

rm -rf "${OUTPUTDIR}"
cp -a "${INPUTDIR}" "${OUTPUTDIR}"

rm "${OUTPUTDIR}"/dists/ragnarok/jotunheimr/binary-armeb/Packages*
rm "${OUTPUTDIR}"/dists/ragnarok/jotunheimr/binary-ppc64/*

sed -i -e '/Description/s/valid/invalid/' "${OUTPUTDIR}"/dists/nosuite/Release
sed -i -e '/Description/s/valid/invalid/' "${OUTPUTDIR}"/dists/nosuite/InRelease
