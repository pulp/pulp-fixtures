#!/usr/bin/bash

set -euo pipefail

assets_dir=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )/assets
output_dir="$(realpath "$1")"

# Complex repository - use all metadata features

mkdir -p "$output_dir"

while IFS= read -r filename
do
  cp --no-preserve=mode --reflink=auto "$assets_dir/packages/$filename" "$output_dir/$filename" ;
done < "$assets_dir/complex_repo_pkglist.txt"

createrepo_c \
  --outputdir="$output_dir" \
  --revision=1615686706 \
  --distro='cpe:/o:fedoraproject:fedora:33,Fedora 33' \
  --content=binary-x86_64 \
  --repo=Fedora \
  --repo=Fedora-Updates \
  --checksum=sha256 \
  --repomd-checksum=sha256 \
  --retain-old-md=0 \
  --simple-md-filenames \
  --no-database \
  --pkglist="$assets_dir/complex_repo_pkglist.txt" \
  "$output_dir"
