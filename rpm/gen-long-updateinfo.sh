#!/usr/bin/env bash
# coding=utf-8
#
# WARNING: Calling this script by hand is not recommended. It should instead be
# called by the pulp-fixtures make file. That's because this script doesn't
# perform the same human-friendly input validation as `./gen-fixtures.sh`, and
# it includes hard-coded relative paths.
#
# Usage:
#
#     gen-long-updateinfo.sh <output_dir>
#
# Behaviour:
#
# 1. Create a temporary directory.
# 2. Copy assets into this directory.
# 3. Overwrite assets_dir/updateinfo.xml.
# 4. Call gen-fixtures.sh, and point it at our patched assets.
# 5. Remove the temporary directory.
#
set -euo pipefail

# Read arguments.
output_dir="${1}"

# Define a procedure for graceful termination.
cleanup() {
    if [ -n "${assets_dir:-}" ]; then
        rm -rf "${assets_dir}"
    fi
}
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM

# Generate patched assets.
assets_dir="$(mktemp --directory)"
cp -rt "${assets_dir}" rpm/assets/*

cat > "${assets_dir}/updateinfo.xml" <<EOF
<?xml version="1.0"?>
<updates>
<update from="errata@redhat.com" status="stable" type="security" version="1">
  <id>RHEA-2012:0055</id>
  <title>Sea_Erratum</title>
  <release>1</release>
  <issued date="2012-01-27 16:08:06"/>
  <updated date="2012-01-27 16:08:06"/>
  <description>Sea_Erratum</description>
  <pkglist>
    <collection short="">
      <name>1</name>
EOF
for _ in {1..20000}; do
cat >> "${assets_dir}/updateinfo.xml" <<EOF
      <package arch="noarch" name="walrus" release="1" src="http://www.fedoraproject.org" version="5.21">
        <filename>walrus-5.21-1.noarch.rpm</filename>
      </package>
      <package arch="noarch" name="penguin" release="1" src="http://www.fedoraproject.org" version="0.9.1">
        <filename>penguin-0.9.1-1.noarch.rpm</filename>
      </package>
      <package arch="noarch" name="shark" release="1" src="http://www.fedoraproject.org" version="0.1">
        <filename>shark-0.1-1.noarch.rpm</filename>
      </package>
EOF
done
cat >> "${assets_dir}/updateinfo.xml" <<EOF
    </collection>
  </pkglist>
</update>
</updates>
EOF

./rpm/gen-fixtures.sh "${output_dir}" "${assets_dir}"
