#!/usr/bin/bash

set -euo pipefail

script_dir=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
assets_dir=$script_dir/assets
packages_dir=$assets_dir/packages
output_dir="$(realpath "$1")"

# create the output directory
mkdir -p "$output_dir"

# Complex repository - use all metadata features
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
  "$packages_dir"
  # --pkglist="$assets_dir/complex_repo_pkglist.txt" \

while IFS= read -r filename
do
  cp --no-preserve=mode --reflink=auto "$assets_dir/packages/$filename" "$output_dir/$filename" ;
done < "$assets_dir/complex_repo_pkglist.txt"
