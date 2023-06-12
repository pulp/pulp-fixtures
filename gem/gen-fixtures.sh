#!/bin/sh

# See https://github.com/rubygems/compact_index for the compact index format.
# See https://github.com/rubygems/new-index and https://andre.arko.net/2014/03/28/the-new-rubygems-index-format/ for the new index format. [NOT USED]

set -eu

SRCDIR=$(readlink -f "$(dirname "$0")")
TMPDIR=$(mktemp -d)
OUTPUTDIR=$(realpath "${SRCDIR}/../$1")

trap 'rm -rf "${TMPDIR}"' EXIT

cd "${TMPDIR}"

mkdir info

for name_version in "amber:1.0.0" "beryl:0.1.0" "diamond:1.2.3" "opal:0.0.1b1" "quartz:1.0.0a1" "quartz:0.9.0"
do
  name="${name_version%:*}"
  version="${name_version#*:}"
  sed -e 's/NAME/'"${name}"'/;s/VERSION/'"${version}"'/' "${SRCDIR}/generic.gemspec" > generic.gemspec
  gem build generic.gemspec

  sha256="$(sha256sum "${name}-${version}.gem" | cut -f 1 -d " ")"

  echo "${name}" >> names.list
  echo "${version} |checksum:${sha256},ruby:>= 1.9" >> "info/${name}"
done

sort -u names.list > unique_names

mkdir -p "${OUTPUTDIR}/gems" "${OUTPUTDIR}/info"
mv -- *.gem "${OUTPUTDIR}/gems"
gem generate_index --directory "${OUTPUTDIR}"

echo "---" > "${OUTPUTDIR}/names.list"
cat unique_names >> "${OUTPUTDIR}/names.list"

echo "created_at: $(date -Iseconds -u)Z" > "${OUTPUTDIR}/versions.list"
echo "---" >> "${OUTPUTDIR}/versions.list"

while read -r name rest
do
  versions="$(cut -d " " -f1 "info/${name}" | tr "\n" ,)"
  echo "---" >> "${OUTPUTDIR}/info/${name}"
  cat "info/${name}" >> "${OUTPUTDIR}/info/${name}"
  md5="$(md5sum "info/${name}" | cut -f 1 -d " ")"
  echo "${name} ${versions%,} ${md5}" >> "${OUTPUTDIR}/versions.list"
done < "unique_names"


cd "${OUTPUTDIR}"
ln -s versions.list versions
ln -s names.list names
