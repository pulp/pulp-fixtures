#!/usr/bin/env bash
# coding=utf-8
#
# Generate a PyPI-compatible Python repository.
#
set -euo pipefail

# See: http://mywiki.wooledge.org/BashFAQ/028
readonly script_name='gen-fixtures.sh'

# Print usage instructions to stdout.
show_help() {
fmt <<EOF
Usage: $script_name <output-dir> <assets-dir> <base-url>

Generate a PyPI-compatible Python repository from the data in <assets-dir>.
Place the repository's contents into <output-dir>. <output-dir> need not exist,
but all parent directories must exist.

<base-url> is the URL of where the fixtures will be hosted. It is needed for
generating absolute URLs.
EOF
}

# Fetch arguments from user.
if [ "$#" -lt 3 ]; then
    echo 1>&2 'Error: Too few arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
elif [ "$#" -gt 3 ]; then
    echo 1>&2 'Error: Too many arguments received.'
    echo 1>&2
    show_help 1>&2
    exit 1
fi
output_dir="$(realpath "$1")"
assets_dir="$(realpath --canonicalize-existing "$2")"
base_url="$3"

# Create a workspace, and schedule it for deletion.
cleanup() { if [ -n "${working_dir:-}" ]; then rm -rf "${working_dir}"; fi }
trap cleanup EXIT  # bash pseudo signal
trap 'cleanup ; trap - SIGINT ; kill -s SIGINT $$' SIGINT
trap 'cleanup ; trap - SIGTERM ; kill -s SIGTERM $$' SIGTERM
working_dir="$(mktemp --directory)"

# Create the Simple API index.html page
mkdir "${working_dir}/simple/"
jinja2 --format json \
    "${assets_dir}/simple/index.html.template" \
    "${assets_dir}/projects.json" \
    > "${working_dir}/simple/index.html"

# Get the list of projects in projects.json
mkdir "${working_dir}/packages"
mapfile -t projects < <(jq --raw-output ".projects|keys|.[]" < "${assets_dir}/projects.json")
for project in "${projects[@]}"; do

    project_norm=$(echo "${project}" | tr '[:upper:]' '[:lower:]')
    # Create the simple distribution index from a jinja template.
    # The simple API should be laid out like:
    #   simple
    #   ├── index.html
    #   ├── Django
    #   │   └── index.html
    #   └── scipy
    #       └── index.html
    mkdir "${working_dir}/simple/${project}"
    jinja2 --format json -D base_url="${base_url}" -D project="${project}" \
        "${assets_dir}/simple/distribution.html.template" \
        "${assets_dir}/projects.json" \
        > "${working_dir}/simple/${project}/index.html"

    # Create the PyPI json API pages
    # This should be laid out like:
    #   pypi
    #   ├── Django
    #   │   │── json
    #   │   │   └── index.json
    #   │      └──{version}
    #   │          └──json
    #   │             └── index.json
    #   └── scipy
    #       │── json
    #       │   └── index.json
    #       └──{version}
    #           └──json
    #              └── index.json
    mkdir -p "${working_dir}/pypi/${project}/json/"

    # Get project JSON metadata from PyPI
    distributions="$(jq ".[\"projects\"]|.[\"${project}\"]" < "${assets_dir}/projects.json")"
    latest_version="$(jq --raw-output ".[\"latest_versions\"]|.[\"${project}\"]" < "${assets_dir}/projects.json")"
    curl --silent "https://pypi.org/pypi/${project}/${latest_version}/json" \
        > "${working_dir}/pypi/${project}/json/latest-json.tmp"
    curl --silent "https://pypi.org/pypi/${project}/json" \
        | "${assets_dir}/pruner.py" - "${distributions}" \
        "${working_dir}/pypi/${project}/json/latest-json.tmp" \
        > "${working_dir}/pypi/${project}/json/index.json.tmp"

    # Get all referenced eggs and wheels
    pushd "${working_dir}/packages"
    mapfile -t urls < <(jq --raw-output '.["releases"]|.[]|.[]|.url' \
        < "${working_dir}/pypi/${project}/json/index.json.tmp")
    for url in "${urls[@]}"; do
        curl --silent -O "${url}" &
    done
    wait
    popd

    # Replace the PyPI urls to point to where the fixture eggs and wheels are located
    "${assets_dir}/urlformatter.py" - "${base_url}" \
        < "${working_dir}/pypi/${project}/json/index.json.tmp" \
        > "${working_dir}/pypi/${project}/json/index.json"

    rm "${working_dir}/pypi/${project}/json/index.json.tmp"
    rm "${working_dir}/pypi/${project}/json/latest-json.tmp"

    #Check if normalized name is different, add normalized name files
    if [ "${project}" != "${project_norm}" ]; then
        mkdir -p "${working_dir}/simple/${project_norm}"
        cp "${working_dir}/simple/${project}/index.html" "${working_dir}/simple/${project_norm}/index.html"
        mkdir -p "${working_dir}/pypi/${project_norm}/json/"
        cp "${working_dir}/pypi/${project}/json/index.json" "${working_dir}/pypi/${project_norm}/json/index.json"
    fi

    # Download the version(releases) jsons & fix their urls
    mapfile -t versions < <(jq --raw-output '.["releases"]|keys|.[]' \
        < "${working_dir}/pypi/${project}/json/index.json")
    for version in "${versions[@]}"; do
      mkdir -p "${working_dir}/pypi/${project}/${version}/json/"
      curl --silent "https://pypi.org/pypi/${project}/${version}/json" \
          | "${assets_dir}/urlformatter.py" - "${base_url}" \
          > "${working_dir}/pypi/${project}/${version}/json/index.json"
      if [ "${project}" != "${project_norm}" ]; then
          mkdir -p "${working_dir}/pypi/${project_norm}/${version}/json/"
          cp "${working_dir}/pypi/${project}/${version}/json/index.json" "${working_dir}/pypi/${project_norm}/${version}/json/index.json"
      fi
    done
done

cp -r --no-preserve=mode --reflink=auto "${working_dir}" "${output_dir}"
