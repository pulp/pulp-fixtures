#!/usr/bin/env bash
# coding=utf-8

set -euo pipefail

DIR=""
TREE=""
USAGE="
Usage: gen-fixtures.sh <output-dir>

Generate an OSTree repository with (2) branches:
 - rawhide
 - stable

Each branch will have (3) commits for versions:
 - 1.0
 - 1.1
 - 1.2

The OSTree repository will be created in <output-dir>.
The directory will be be created.
"

show_help()
{
  echo "${USAGE}"
}

_mkdir()
{
  if [ -e "${DIR}" ]; then
    if [ ! -z "$(ls -A "${DIR}")" ]; then
      echo 1>&2 ""
      echo 1>&2 "${DIR} must be empty."
      echo 1>&2 ""
      exit 1
    fi
  else
    mkdir -p "${DIR}"
  fi
}

gen_tree()
{
  # The tree used for the ostree commits must be a directory
  # containing at least (1) file.  Using this script for convenience.
  TREE=$(mktemp -d /tmp/tree.XXXXX)
  touch "${TREE}/fake.img"
}

gen_repository()
{
  ostree init --repo="${DIR}" --mode=archive-z2
  # branch: rawhide
  ostree commit --repo="${DIR}" -b rawhide --add-metadata-string=version=1.1 "${TREE}"
  ostree commit --repo="${DIR}" -b rawhide --add-metadata-string=version=1.2 "${TREE}"
  ostree commit --repo="${DIR}" -b rawhide --add-metadata-string=version=1.3 "${TREE}"
  # branch: stable
  ostree commit --repo="${DIR}" -b stable --add-metadata-string=version=1.1 "${TREE}"
  ostree commit --repo="${DIR}" -b stable --add-metadata-string=version=1.2 "${TREE}"
  ostree commit --repo="${DIR}" -b stable --add-metadata-string=version=1.3 "${TREE}"
  # summary
  ostree summary -u --repo="${DIR}"
}

clean()
{
  if [ -d "${TREE}" ]; then
    rm -rf "${TREE}"
  fi
}


if [ "$#" -ne "1" ]; then
  show_help
  exit 1
fi

DIR="$1"

trap clean EXIT

_mkdir
gen_tree
gen_repository
clean
echo "Created repository in: ${DIR}"

