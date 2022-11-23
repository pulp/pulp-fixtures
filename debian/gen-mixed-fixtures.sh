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
  equivs-build --arch amd64 "${SRCDIR}/asgard_mixed/baldr.ctl"
  equivs-build "${SRCDIR}/asgard_mixed/eir.ctl"
  equivs-build --arch ppc64 "${SRCDIR}/asgard_mixed/frigg.ctl"
)

mkdir nidavellir
(
  cd nidavellir
  equivs-build --arch amd64 "${SRCDIR}/nidavellir/hreidmar.ctl"
  equivs-build "${SRCDIR}/nidavellir/regin.ctl"
  equivs-build --arch ppc64 "${SRCDIR}/nidavellir/fafner.ctl"
)

cp -a "${SRCDIR}/conf" .
reprepro -C asgard includedeb muspelheim asgard/baldr_1.0_amd64.deb
reprepro includedeb muspelheim asgard/eir_1.0_all.deb
reprepro -C asgard includedeb muspelheim asgard/frigg_1.0_ppc64.deb
reprepro -C nidavellir includedeb muspelheim nidavellir/hreidmar_1.0_amd64.deb
reprepro -C nidavellir includedeb muspelheim nidavellir/regin_1.0_all.deb
reprepro -C nidavellir includedeb muspelheim nidavellir/fafner_1.0_ppc64.deb

# Rename binary-armeb to binary-all
mv "${TMPDIR}/dists/muspelheim/asgard/binary-armeb" "${TMPDIR}/dists/muspelheim/asgard/binary-all"
mv "${TMPDIR}/dists/muspelheim/nidavellir/binary-armeb" "${TMPDIR}/dists/muspelheim/nidavellir/binary-all"

sed -i -e "s/armeb/all/g" "${TMPDIR}/dists/muspelheim/Release"
sed -i -e "s/armeb/all/g" "${TMPDIR}/dists/muspelheim/InRelease"
sed -i -e "s/armeb/all/g" "${TMPDIR}/dists/muspelheim/asgard/binary-all/Release"
sed -i -e "s/armeb/all/g" "${TMPDIR}/dists/muspelheim/nidavellir/binary-all/Release"

# Add the 'No-Support-for-Architecture-all' metadata to the Release file
sed -i "3 i No-Support-for-Architecture-all: Packages" "${TMPDIR}/dists/muspelheim/Release"
sed -i "5 i No-Support-for-Architecture-all: Packages" "${TMPDIR}/dists/muspelheim/InRelease"

# Update Release and InRelease with the new checksums and file size
mapfile -t releases < <(grep -rl --exclude=*.db Release)

components=("asgard" "nidavellir")

for release in "${releases[@]}"; do
  for component in "${components[@]}"; do
    md5=$(md5sum "${TMPDIR}/dists/muspelheim/${component}/binary-all/Release" | awk '{print $1}')
    sha1=$(sha1sum "${TMPDIR}/dists/muspelheim/${component}/binary-all/Release" | awk '{print $1}')
    sha256=$(sha256sum "${TMPDIR}/dists/muspelheim/${component}/binary-all/Release" | awk '{print $1}')
    checksums=("${md5}" "${sha1}" "${sha256}")
    filesize=$(find "${TMPDIR}/dists/muspelheim/${component}/binary-all/Release" -print0 | xargs stat -c "%s")
    mapfile -t lines < <(grep -n "${component}/binary-all/Release" "${TMPDIR}/${release}" | cut -d : -f 1)

    i=0
    for line in "${lines[@]}"; do
      sed -i "${line}s/.*/ ${checksums[i]} ${filesize} ${component}\/binary-all\/Release/" "${TMPDIR}/${release}"
      ((i = i + 1))
    done
  done
done

mkdir -p "${OUTPUTDIR}"
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/dists -t "${OUTPUTDIR}"
cp -r --no-preserve=mode --reflink=auto "${TMPDIR}"/pool -t "${OUTPUTDIR}"
